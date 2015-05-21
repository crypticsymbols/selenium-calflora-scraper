This is just a super simple example of screen scraping using selenium. It is hastily written, not pretty, sledgehammer-y, but functional. If I'm trying to get a job with you please ignore this repository.

It was written to harvest data from a calflora.org, a site which seemed determined to thwart any reasonable approach to scraping. Using the Selenium IDE in Firefox to start writing the first 33% of the scraper took care of a lot of the boring details (waiting for ajax-y elements to load, nasty xpath selectors, etc). Once I had harvested what was only possible to grab with a javascript-y browser, I moved on to Nokogiri for most of the fetch/parse heavy lifting.

Please feel free to use this code in any way you want - IDGAF License.
