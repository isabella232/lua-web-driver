--- Firefox driver
--
-- @classmod FirefoxDriver
local process = require("process")

local Bridge = require("web-driver/bridge")
local Session = require("web-driver/session")
local util = require("web-driver/util")

local FirefoxDriver = {}

local methods = {}
local metatable = {}

function metatable.__index(driver, key)
  -- driver is a FirefoxDriver instance
  return methods[key]
end

local DEFAULT_HOST = "127.0.0.1"
local DEFAULT_PORT = "4444"
local DEFAULT_CAPABILITIES = {
  capabilities = {
    alwaysMatch = {
      acceptInsecureCerts = true,
      ["moz:firefoxOptions"] = {
        args = { "-headless" }
      }
    }
  }
}

function methods:browser()
  return "firefox"
end

function methods:start(callback)
  local command_name = "geckodriver"
  local args = {
    "--host", self.bridge.host,
    "--port", self.bridge.port
  }
  local child_process, err = process.exec(command_name, args)
  if err then
     error("lua-web-driver: Failed to execute " .. command_name .. ": " .. err)
  end
  self.child_process = child_process
  if not self:wait_for_ready() then
    error("Timeout: geckodriver may not be running")
  end
  if callback then
    local _, err = pcall(callback, self)
    self:stop()
    if err then
      error(err)
    end
  end
end

function methods:status()
  local success, response
  for _ = 1, 10 do
    success, response = pcall(self.bridge.status, self.bridge)
    process.nsleep(100000) -- 100 usec
    if success then
      return response.json()["value"]
    end
  end
  return { ready = false, message = "Timeout: geckodriver may not be running" }
end

function methods:is_ready()
  return self:status()["ready"]
end

function methods:wait_for_ready()
  for i = 1, 10 do
    if self:is_ready() then
      return true
    end
    process.nsleep((100 * 10^3) * i) -- 100 usec * i
  end
  return false
end

function methods:stop()
  self.child_process:kill()
end

function methods:start_session(callback)
  if callback then
    Session.start(self, self.capabilities, callback)
  else
    return Session.new(self, self.capabilities)
  end
end

local function set_options(options)
  if not options then
    return DEFAULT_HOST, DEFAULT_PORT, DEFAULT_CAPABILITIES
  end

  local host = options.host
  local port = options.port
  local capabilities = {
    capabilities = {
      alwaysMatch = {
        acceptInsecureCerts = true,
        ["moz:firefoxOptions"] = {
          args = options
        }
      }
    }
  }
  return host, port, capabilities
end

function FirefoxDriver.new(options)
  local host, port, capabilities = set_options(options)
  local firefox_driver = {
    options = options,
    bridge = Bridge.new(host, port),
    capabilities = capabilities
  }
  setmetatable(firefox_driver, metatable)
  return firefox_driver
end

return FirefoxDriver
