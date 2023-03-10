# Generated by Selenium IDE
require 'selenium-webdriver'
require 'json'
describe 'Testfiltercountries' do
  before(:each) do
    @driver = Selenium::WebDriver.for :chrome
    @vars = {}
  end
  after(:each) do
    @driver.quit
  end
  it 'testfiltercountries' do
    @driver.get('http://localhost:3000/')
    sleep 1
    @driver.manage.window.resize_to(1846, 1016)
    sleep 1
    @driver.find_element(:css, '#panelsStayOpen-headingThree > .accordion-button').click
    sleep 1
    @driver.find_element(:css, '.my-form-check:nth-child(1)').click
    sleep 1
    @driver.find_element(:css, '.my-form-check:nth-child(1) > #flexCheckDefault').click
    sleep 1
    @driver.find_element(:id, 'btn-acc').click
    sleep 1
    @driver.find_element(:css, '.card:nth-child(1) .card-text:nth-child(2)').click
    sleep 1
    expect(@driver.find_element(:css, '.card:nth-child(1) .card-text:nth-child(2)').text).to eq('Страны: США,')
    sleep 1
    @driver.find_element(:css, '#panelsStayOpen-headingThree > .accordion-button').click
    sleep 1
    @driver.find_element(:css, '.my-form-check:nth-child(1) > #flexCheckDefault').click
    sleep 1
    @driver.find_element(:css, '.my-form-check:nth-child(3) > #flexCheckDefault').click
    sleep 1
    @driver.find_element(:id, 'btn-acc').click
    sleep 1
    @driver.find_element(:css, '.card:nth-child(1) .card-text:nth-child(2)').click
    sleep 1
    expect(@driver.find_element(:css, '.card:nth-child(1) .card-text:nth-child(2)').text).to eq('Страны: Великобритания, США,')
    sleep 1
    @driver.close
  end
end
