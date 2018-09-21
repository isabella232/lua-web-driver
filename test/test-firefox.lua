local luaunit = require("luaunit")
local FirefoxDriver = require("web-driver/firefox")

TestFirefoxDriver = {}

function TestFirefoxDriver:test_browser()
  local driver = FirefoxDriver.new()
  luaunit.assert_equals(driver:browser(), "firefox")
end

function TestFirefoxDriver:test_default_options()
  local driver = FirefoxDriver.new()
  luaunit.assert_equals(driver.bridge.base_url, "http://127.0.0.1:4444/")
end

function TestFirefoxDriver:test_start_without_callback()
  local driver = FirefoxDriver.new()
  driver:start()
  local session = driver:start_session()
  session:destroy()
  driver:stop()
end

