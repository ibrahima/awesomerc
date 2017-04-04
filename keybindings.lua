local gears = require("gears")
local awful = require("awful")
local scratchdrop = require("scratchdrop")

local modkey = "Mod4"
local keybindings = gears.table.join(
   -- Volume keys
   awful.key({ }, "XF86AudioRaiseVolume", function ()
         awful.util.spawn("amixer -c 1 -q set Master 2dB+") end),
   awful.key({ }, "XF86AudioLowerVolume", function ()
         awful.util.spawn("amixer -c 1 -q set Master 2dB-") end),
   awful.key({ }, "XF86AudioMute", function ()
         awful.util.spawn("amixer -c 1 -D pulse set Master 1+ toggle") end),
   -- Scratchdrop
   awful.key({ modkey }, "`", function() scratchdrop("evilvte -g +10+10", "bottom", "center", 1920, 320, false) end)

)

return keybindings
