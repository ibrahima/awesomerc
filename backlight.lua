---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2014, ibrahima <ibrahim.awwal@gmail.com@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}

local backlight = {}

-- {{{ AC widget type
local function worker(format, warg)
    local bl = helpers.pathtotable("/sys/class/backlight/")

    local intel = bl.intel_backlight
    local bl_val = 0
    if intel == nil then
        return {"N/A"}
    else
       bl_val = intel.actual_brightness/intel.max_brightness*100
       return {bl_val}
    end
end
-- }}}


return setmetatable(backlight, { __call = function(_, ...) return worker(...) end })
