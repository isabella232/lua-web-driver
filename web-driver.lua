--- WebDriver interface for Lua
--
-- @author Kenji Okimoto <okimoto@clear-code.com>
-- @author Horimoto Yasuhiro <horimoto@clear-code.com>
-- @author Kouhei Sutou <kou@clear-code.com>
-- @copyright 2018
-- @license MIT
local web_driver = {}

web_driver.VERSION = "0.0.5"
web_driver.Firefox = require("web-driver/firefox")
web_driver.Pool = require("web-driver/pool")

return web_driver
