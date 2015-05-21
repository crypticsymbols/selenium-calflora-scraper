require "json"
require "selenium-webdriver"
gem "test-unit"
require "test/unit"
require_relative 'Parser'

class Export < Test::Unit::TestCase

  def species
    [
      'Lychnis coronaria',
      'Silene aperta',
      'Silene bernardina',
      'Silene bolanderi',
      'Silene bridgesii',
      'Silene campanulata',
      'Silene douglasii',
      'Silene grayi',
      'Silene hookeri',
      'Silene invisa',
      'Silene laciniata',
      'Silene latifolia',
      'Silene lemmonii',
      'Silene marmorensis',
      'Silene menziesii',
      'Silene nuda',
      'Silene occidentalis',
      'Silene oregana',
      'Silene parishii',
      'Silene pendula',
      'Silene salmonacea',
      'Silene sargentii',
      'Silene scouleri',
      'Silene serpentinicola',
      'Silene suksdorfii',
      'Silene verecunda ssp. verecunda',
      'Silene vulgaris'
    ]
  end

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://www.calflora.org/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
    @links = []
  end
  
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
    Parser.parse(@links)
  end
  
  def test_export
    @driver.get(@base_url + "/entry/observ.html")
    
    @driver.find_element(:css, "input#gwt-uid-6").click # Search anywhere
    @driver.find_element(:xpath, '//*[@id="critSlot"]/table/tbody/tr[9]/td[1]/a/table/tbody/tr/td[3]/div').click # Other sources
    @driver.find_element(:css, "input#gwt-uid-10").click # Consortium of California Herbaria
    @driver.find_element(:css, "input#gwt-uid-11").click # iNaturalist
      
    species_found = {}
    species.each do |s|
      @driver.find_element(:css, "input.A9").clear
      @driver.find_element(:css, "input.A9").send_keys "#{s}"
      @driver.find_element(:css, "button.A10").click
      sleep 2
      # Count number of results
      results = @driver.find_elements(:css, ".idCell").count
      i = 0
      # Loop through each row and harvest the href attribute
      @driver.find_elements(:css, "td.idCell a").each do |l|
        l.click
        sleep 0.1 # just in case, really.
        @links << @driver.find_element(:css, ".yellowPop a.bgrayLink").attribute('href')
        i+=1
        puts "Harvested #{i} of #{results} for #{s}"
      end
      species_found[s] = i
    end
    species_found.each do |s, n|
      puts "#{n} results found for #{s}"
    end
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
