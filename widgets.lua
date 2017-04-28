local vicious = require("vicious")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

-- Separator widget
separator = wibox.widget.textbox()
separator:set_text("::");

-- CPU Graph Widget
cpuwidget = wibox.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"},
                                                                                 {1, "#AECF96" }}})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

-- Memory consumption widget
memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, "RAM: $1%", 13)

-- CPU Frequency Widgets
one_decimal = function(widget, args)
   return string.format("%.1f|", args[2])
end

freq0 = wibox.widget.textbox()
-- vicious.cache(vicious.widgets.cpufreq)
vicious.register(freq0, vicious.widgets.cpufreq, one_decimal, 7, "cpu0")
freq1 = wibox.widget.textbox()
vicious.register(freq1, vicious.widgets.cpufreq, one_decimal, 7, "cpu1")
freq2 = wibox.widget.textbox()
vicious.register(freq2, vicious.widgets.cpufreq, one_decimal, 7, "cpu2")
freq3 = wibox.widget.textbox()
vicious.register(freq3, vicious.widgets.cpufreq,
                 function(widget, args)
                    return string.format("%.1f%s", args[2], args[5])
                 end, 7, "cpu3")

-- Battery bar widget
batwidget = function(bat)
   local batbar = wibox.widget {
      max_value     = 1,
      value         = 0.5,
      forced_width  = 65,
      paddings      = 0,
      border_width  = 1,
      border_color  = "#1ca9c4",
      background_color = "#4a4a4a",
      color = { type = "linear", from = { 0, 0 }, to = { 50, 0 },
                stops = { { 0, "#de6868" }, { 0.5, "#88A175" }, { 1, "#1ca9c4" }} },
      widget        = wibox.widget.progressbar,
   }

   vicious.register(batbar, vicious.widgets.bat, "$2", 61, bat)
   battime = wibox.widget {
      border_color = "#ff0000",
      align = center,
      forced_width  = 65,
      widget = wibox.widget.textbox
   }
   vicious.register(battime, vicious.widgets.bat, "<span color=\"white\">($3)$1</span>", 61, bat)

   return wibox.widget {
    batbar,
    battime,
    layout = wibox.layout.stack
   }
end

batwidget0 = batwidget('BAT0')
batwidget1 = batwidget('BAT1')

-- Battery time widgets
battime0 = wibox.widget.textbox()
battime1 = wibox.widget.textbox()
vicious.register(battime0, vicious.widgets.bat, "($3)$1", 61, "BAT0")
vicious.register(battime1, vicious.widgets.bat, "($3)$1", 61, "BAT1")

local widgets = {
   separator = separator,
   cpuwidget = cpuwidget,
   memwidget = memwidget,
   batwidget0 = batwidget0,
   batwidget1 = batwidget1,
   battime0 = battime0,
   battime1 = battime1,
   freq0 = freq0,
   freq1 = freq1,
   freq2 = freq2,
   freq3 = freq3
}

return widgets
