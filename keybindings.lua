local gears = require("gears");
local awful = require("awful");

local keybindings = gears.table.join(
   -- Volume keys
   awful.key({ }, "XF86AudioRaiseVolume", function ()
         awful.util.spawn("amixer -c 1 -q set Master 2dB+") end),
   awful.key({ }, "XF86AudioLowerVolume", function ()
         awful.util.spawn("amixer -c 1 -q set Master 2dB-") end),
   awful.key({ }, "XF86AudioMute", function ()
         awful.util.spawn("amixer -c 1 -D pulse set Master 1+ toggle") end)
)

return keybindings
