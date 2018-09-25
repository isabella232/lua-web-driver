--- The class to handle web elements
--
-- @classmod Element
local ElementClient = require("web-driver/element-client")
local util = require "web-driver/util"
local base64 = require("base64")
local Element = {}

local methods = {}
local metatable = {}

function metatable.__index(element, key)
  return methods[key]
end

-- TODO: Support more patterns
function metatable.__tostring(element)
  local tag = element:tag_name()
  local s = "<"..tag
  local id = element:get_property("id")
  if id then
    s = s..' id="'..id..'"'
  end
  if tag == "input" then
    local type_property = element:get_property("type")
    if type_property then
      s = s..' type="'..type_property..'"'
    end
    local name_property = element:get_property("name")
    if name_property then
      s = s..' name="'..name_property..'"'
    end
  end
  s = s..">"
  return s
end

function methods:find_child_element(strategy, finder)
  local response = self.client:find_child_element(strategy, finder)
  local id = response.json()["value"]
  return Element.new(self.session, id)
end

function methods:find_child_elements(strategy, finder)
  local response = self.client:find_child_elements(strategy, finder)
  local elements = {}
  for i, id in ipairs(response.json()["value"]) do
    elements[i] = Element.new(self.session, id)
  end
  return elements
end

function methods:is_selected()
  local response = self.client:is_selected()
  return response.json()["value"]
end

function methods:get_attribute(name)
  local response = self.client:get_attribute(name)
  return response.json()["value"]
end

function methods:get_property(name)
  local response = self.client:get_property(name)
  return response.json()["value"]
end

function methods:get_css_value(property_name)
  local response = self.client:get_css_value(property_name)
  return response.json()["value"]
end

function methods:text()
  local response = self.client:get_text()
  return response.json()["value"]
end

function methods:tag_name()
  local response = self.client:get_tag_name()
  return response.json()["value"]
end

function methods:rect()
  local response = self.client:get_rect()
  return response.json()["value"]
end

function methods:is_enabled()
  local response = self.client:is_enabled()
  return response.json()["value"]
end

function methods:click()
  local response = self.client:click()
  return response
end

function methods:clear()
  local response = self.client:clear()
  return response
end

--- Send keys to element
-- TODO Support Element Send Keys specification
-- <https://www.w3.org/TR/webdriver/#dfn-element-send-keys>
-- @function Element:send_keys
-- @param keys must be string
function methods:send_keys(keys)
  local response = self.client:send_keys({ text = keys })
  return response
end

function methods:save_screenshot(filename)
  local response = self.client:take_screenshot()
  local binary = base64.decode(response.json()["value"])
  local file_handle, err = io.open(filename, "wb+")
  if err then
    error(err)
  end
  file_handle:write(binary)
  file_handle:close()
end

function methods:to_data()
  -- This method supports W3C WebDriver only
  return { ["element-6066-11e4-a52e-4f735466cecf"] = self.id }
end

function Element.new(session, id)
  if type(id) == "table" then
    -- Why should we check "ELEMENT" here?
    id = id["ELEMENT"] or id["element-6066-11e4-a52e-4f735466cecf"]
  end
  local element = {
    client = ElementClient.new(session.client.host,
                               session.client.port,
                               session.id,
                               id),
    session = session,
    id = id,
  }
  setmetatable(element, metatable)
  return element
end

return Element
