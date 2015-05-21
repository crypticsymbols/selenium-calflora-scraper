require 'json'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'uri'

class Parser

	def self.parse_domain(url)
		URI(url).host
	end

	def self.parse_row(row, url)

		if self.parse_domain(url) == 'www.calflora.org'
			key = row.css('td.labelCell').text
		elsif self.parse_domain(url) == 'ucjeps.berkeley.edu'
			key = row.css('td:nth-child(1)').text
		end

		if (key == 'Plant Name' || key == 'Determination')
			key = 'Species'
		end

		if self.parse_domain(url) == 'www.calflora.org'
			value = row.xpath('td[starts-with(@class, "data")]').text
			value = value.split(':')[0] if key == 'Coordinates'

		elsif self.parse_domain(url) == 'ucjeps.berkeley.edu'
			row.search("a").each do |e|
				e.remove
			end
			value = row.css('td:nth-child(2)').text
			value = value.gsub(' ', ',').gsub(',,', ',') if key == "Coordinates"
		end

		return key, value
	end

	def self.parse(links)
		puts "=================================="
		puts "Parsing #{links.length} links..."
		puts "=================================="

		unique_headings = {'source' => true}

		results = {}

		links.each do |l, idx|
			results["#{l}"] = {}
			puts "Nokogiri fetching #{idx} of #{links.count} from URL #{l}"
			doc = Nokogiri::HTML(open("#{l}"))

			if self.parse_domain(l) == 'www.calflora.org'
				results_selector = 'table.fxt table.fxt tr'
			elsif self.parse_domain(l) == 'ucjeps.berkeley.edu'
				results_selector = 'body table:nth-of-type(3) tr'
			else
				results_selector = 'idk'
			end

			results["#{l}"]['source'] = l

			doc.css(results_selector).each do |row|
				row.search("style").each do |e|
					e.remove
				end
				key, value = self.parse_row(row, l)
				unique_headings["#{key}"] = true

				results["#{l}"]["#{key}"] = value.scrub.delete("\n").gsub(/\u00a0/, ' ').strip.chomp(',')
			end
		end

		puts "Wow! Done fetching and parsing."

		CSV.open("data.csv", "wb", write_headers: true, headers: unique_headings.keys) do |csv| 
			puts 'Opening CSV...'
			# for each unique key we saw...
			results.each do |k, v|
				to_add = []
				unique_headings.keys.each do |k2|
					to_add << v["#{k2}"] rescue nil
				end
				csv << to_add
			end

		end
	end

end