local options = {
  args = { "-headless" }
}

local WebDriver = require("web-driver")
local driver = WebDriver.create("firefox", options)

function callback(session)
  session:visit("https://www.google.com/")
  local xml = session:xml()
  print(xml)
end

driver:start()
driver:start_session(callback)
driver:stop()
