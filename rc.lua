-- Override awesome.quit when we're using GNOME
_awesome_quit = awesome.quit
awesome.quit = function()
   if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
      os.execute("/usr/bin/gnome-session-quit  --logout --no-prompt")
   else
      _awesome_quit()
   end
end

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local scratchdrop = require("scratchdrop")
local backlight = require("backlight")
local hotkeys_popup = require("awful.hotkeys_popup").widget

require("debian.menu")
vicious = require("vicious")

awful.util.spawn_with_shell("compton -cfb --config ~/.config/compton.conf")
io.stderr:write("Awesome is starting\n");
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")

beautiful.wallpaper = "/home/ibrahim/Pictures/mirror_lake.jpg"

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
-- tags = {}
-- for s = 1, screen.count() do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[2])
-- end
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Ubuntu", debian.menu.Debian_menu.Debian },
                                    { "Terminal", terminal },
            { "Log Out", "/home/ibrahim/bin/power_menu.sh" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(" %a %b %d, %I:%M%p")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, client_menu_toggle_fn()),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                    awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"},
                                                                                 {1, "#AECF96" }}})
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, "RAM: $1%", 13)

one_decimal = function(widget, args)
   return string.format("%.1f|", args[2])
end
freq0 = wibox.widget.textbox()
-- vicious.cache(vicious.widgets.cpufreq)
vicious.register(freq0, vicious.widgets.cpufreq, one_decimal, 7, "cpu0")
freq1 = wibox.widget.textbox()
vicious.register(freq1, vicious.widgets.cpufreq, one_decimal,7, "cpu1")
freq2 = wibox.widget.textbox()
vicious.register(freq2, vicious.widgets.cpufreq, one_decimal,7, "cpu2")
freq3 = wibox.widget.textbox()
vicious.register(freq3, vicious.widgets.cpufreq,
                 function(widget, args)
                    return string.format("%.1f%s", args[2], args[5])
                 end, 7, "cpu3")

-- Initialize widget
separator = wibox.widget.textbox()
separator:set_text("::");

batwidget0 = awful.widget.progressbar()
batwidget0:set_width(8)
batwidget0:set_height(10)
batwidget0:set_vertical(true)
batwidget0:set_background_color("#494B4F")
batwidget0:set_border_color(nil)
batwidget0:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 },
                       stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" }} })
vicious.register(batwidget0, vicious.widgets.bat, "$2", 61, "BAT0")

batwidget1 = awful.widget.progressbar()
batwidget1:set_width(8)
batwidget1:set_height(10)
batwidget1:set_vertical(true)
batwidget1:set_background_color("#494B4F")
batwidget1:set_border_color(nil)
batwidget1:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 },
                       stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" }} })
vicious.register(batwidget1, vicious.widgets.bat, "$2", 61, "BAT1")

battime0 = wibox.widget.textbox()
battime1 = wibox.widget.textbox()
vicious.register(battime0, vicious.widgets.bat, "($3)$1", 61, "BAT0")
vicious.register(battime1, vicious.widgets.bat, "($3)$1", 61, "BAT1")
-- {{{ Volume level
volicon = wibox.widget.textbox() --widget({ type = "imagebox" })
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = wibox.widget.textbox() -- widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
-- volbar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 },
--                        stops = { { 0, beautiful.fg_widget }, { 0.5, beautiful.fg_center_widget }, { 1, beautiful.fg_end_widget }} })
volbar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 },
                       stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" }} })

-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  1, "-c 1 Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 1, "-c 1 Master")
vicious.register(volicon, vicious.widgets.volume, " $2", 1, "-c 1 Master")
-- Register buttons
volbar:buttons(awful.util.table.join(
                         -- awful.button({ }, 1, function () awful.util.spawn("kmix") end),
                         awful.button({ }, 4, function () awful.util.spawn("amixer -q -c 1 set Master 2dB+", false) end),
                         awful.button({ }, 5, function () awful.util.spawn("amixer -q -c 1 set Master 2dB-", false) end)
)) -- Register assigned buttons
volwidget:buttons(volbar:buttons())
-- }}}

-- Brightness widget
brightbar = awful.widget.progressbar()
brightbar:set_vertical(true):set_ticks(true)
brightbar:set_height(12):set_width(8):set_ticks_size(2)
brightbar:set_background_color(beautiful.fg_off_widget)
brightbar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 10 },
                       stops = { { 0, "#AECF96" }, { 0.5, "#88A175" }, { 1, "#FF5656" }} })
vicious.cache(backlight)
vicious.register(brightbar, backlight, "$1", 11)

--  Network usage widget
-- Initialize widget, use widget({ type = "textbox" }) for awesome < 3.5
netwidget = wibox.widget.textbox()
 -- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${wlan0 down_kb}</span> <span color="#7F9F7F">${wlan0 up_kb}</span>', 3)

mwidget = wibox.widget.textbox()
 -- Register widget
vicious.register(mwidget, vicious.widgets.mdir, "$1<b>✉</b>",  3, {"/home/ibrahim/Maildir/iawwal@eng.ucsd.edu/INBOX",
                                                           "/home/ibrahim/Maildir/ibrahim.awwal@gmail.com/INBOX"})

orgwidget = wibox.widget.textbox()
 -- Register widget
vicious.register(orgwidget, vicious.widgets.org, "$1 $2 $3 $4",  3, {"/home/ibrahim/SparkleShare/braindump/gradescope.org", "/home/ibrahim/SparkleShare/braindump/misc.org"})
vicious.cache(vicious.widgets.org)

-- Org mode current task widget
orgtaskwidget = wibox.widget.textbox()

updateorgtask = function()
   f = io.open("/home/ibrahim/.current-task")
   t = f:read("*line")
   orgtaskwidget:set_text(string.sub(t, 1, 30))
end

updateorgtask()

--Create a weather widget
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
location = trim(awful.util.pread("curl ipinfo.io/loc"))
city = awful.util.pread("curl ipinfo.io/city")
weatherwidget = wibox.widget.textbox()
weatherwidget:set_text(awful.util.pread(
   "weather " .. location .. " --headers=Temperature --quiet | awk '{print $2, $3}'"
)) -- replace METARID with the metar ID for your area. This uses metric. If you prefer Fahrenheit remove the "-m" in "--quiet -m".
degrees=awful.util.pread(
   "weather " .. location .. " --headers=Temperature --quiet | awk '{print $2, $3}'"
)
weathertimer = timer(
   { timeout = 900 } -- Update every 15 minutes.
)
weathertimer:connect_signal(
   "timeout", function()
      weatherwidget:set_text(awful.util.pread(
         "weather " .. location .. " --headers=Temperature --quiet | awk '{print $2, $3}' &"
      )) --replace METARID and remove -m if you want Fahrenheit
end)

weathertimer:start() -- Start the timer
weatherwidget:connect_signal(
   "mouse::enter", function()
      weather = naughty.notify(
         {title="Weather",text=awful.util.pread("weather "..location)})
      weatherwidget:set_text(awful.util.pread(
   "weather " .. location .. " --headers=Temperature --quiet | awk '{print $2, $3}'"
      ))
end) -- this creates the hover feature. replace METARID and remove -m if you want Fahrenheit

weatherwidget:connect_signal(
   "mouse::leave", function()
      naughty.destroy(weather)
end)


mytimer = timer({ timeout = 30 })
mytimer:connect_signal("timeout", updateorgtask)
mytimer:start()


-- for s = 1, screen.count() do
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    if beautiful.wallpaper then
       local wallpaper = beautiful.wallpaper
       -- If wallpaper is a function, call it with the screen
       if type(wallpaper) == "function" then
          wallpaper = wallpaper(s)
       end
       gears.wallpaper.maximized(wallpaper, s, true)
    end

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[2])

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                              awful.button({ }, 1, function () awful.layout.inc( 1) end),
                              awful.button({ }, 3, function () awful.layout.inc(-1) end),
                              awful.button({ }, 4, function () awful.layout.inc( 1) end),
                              awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = "top", screen = s })


    mywibox[s]:setup {
       layout = wibox.layout.align.horizontal,
       { -- Left widgets
          layout = wibox.layout.fixed.horizontal,
          mylauncher,
          mytaglist[s],
          mypromptbox[s],
       },
       mytasklist[s], -- Middle widget
       { -- Right widgets
          layout = wibox.layout.fixed.horizontal,
          separator,
          orgtaskwidget,
          separator,
          brightbar,
          separator,
          netwidget,
          separator,
          mwidget,
          separator,
          orgwidget,
          separator,
          volwidget,
          volbar,
          volicon,
          separator,
          memwidget,
          separator,
          cpuwidget,
          freq0,
          freq1,
          freq2,
          freq3,
          separator,
          batwidget0,
          battime0,
          batwidget1,
          battime1,
          separator,
          weatherwidget,
          mykeyboardlayout,
          wibox.widget.systray(),
          mytextclock,
          mylayoutbox[s],
       },
                     }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey,            }, "s",      hotkeys_popup.show_help,
          {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    -- display manipulation commands
    awful.key({ modkey,           }, "[", function () awful.util.spawn("disper -d eDP-1,HDMI-1 -t top -e") end),
    awful.key({ modkey,           }, "]", function () awful.util.spawn("disper -d eDP-1,HDMI-1 -s") end),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[awful.screen.focused()]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Volume keys
   awful.key({ }, "XF86AudioRaiseVolume", function ()
                awful.util.spawn("amixer -c 1 -q set Master 2dB+") end),
   awful.key({ }, "XF86AudioLowerVolume", function ()
                awful.util.spawn("amixer -c 1 -q set Master 2dB-") end),
   awful.key({ }, "XF86AudioMute", function ()
                awful.util.spawn("amixer -c 1 -D pulse set Master 1+ toggle") end),

   -- Scratchdrop
    awful.key({ modkey }, "`", function() scratchdrop("evilvte -g +10+10", "bottom", "center", 1920, 320, false) end)
    -- Parameters:
    --   prog   - Program to run; "urxvt", "gmrun", "thunderbird"
    --   vert   - Vertical; "bottom", "center" or "top" (default)
    --   horiz  - Horizontal; "left", "right" or "center" (default)
    --   width  - Width in absolute pixels, or width percentage
    --            when <= 1 (1 (100% of the screen) by default)
    --   height - Height in absolute pixels, or height percentage
    --            when <= 1 (0.25 (25% of the screen) by default)
    --   sticky - Visible on all tags, false by default
    --   screen - Screen (optional), mouse.screen by default
    -- Load Debian menu entries

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
if screen.count() == 1 then
   awful.rules.rules = {
      -- All clients will match this rule.
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       raise = true,
                       keys = clientkeys,
                       buttons = clientbuttons,
                       placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
      },
      { rule = { class = "MPlayer" },
        properties = { floating = true } },
      { rule = { class = "Guake" },
        properties = { floating = true } },
      { rule = { class = "pinentry" },
        properties = { floating = true } },
      { rule = { class = "gimp" },
        properties = { floating = true } },
      { rule = { class = "mathworks", name = "Figure" },
        properties = { floating = true } },
      -- { rule = { class = "Google-chrome" },
      --   properties = { tag = tags[1][2] } },
      { rule = { class = "Emacs" },
        properties = { screen = 1, tag = "1" } },
      { rule = { class = "Pidgin" },
        properties = { screen = 1, tag = "4" } },
      -- Set Firefox to always map on tags number 2 of screen 1.
      { rule = { class = "Firefox" },
        properties = { screen = 1, tag = "2" } },
      { rule = { class = "google-chrome", name = "Hangouts" },
        properties = { screen = 1, tag = "8", sticky = false, ontop=true, border_width = 0 } },
      { rule = { class = "google-chrome", role = "pop-up" },
        properties = { screen = 1, tag = "8", sticky = false, ontop=true, border_width = 0 } },
   }
else
   awful.rules.rules = {
      -- All clients will match this rule.
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       keys = clientkeys,
                       buttons = clientbuttons } },
      { rule = { class = "MPlayer" },
        properties = { floating = true } },
      { rule = { class = "Guake" },
        properties = { floating = true } },
      { rule = { class = "pinentry" },
        properties = { floating = true } },
      { rule = { class = "gimp" },
        properties = { floating = true } },
      { rule = { class = "mathworks", name = "Figure" },
        properties = { floating = true } },
      { rule = { class = "google-chrome" },
        properties = { screen = 1, tag = "2" } },
      { rule = { class = "Emacs" },
        properties = { screen = 1, tag = "1" } },
      { rule = { class = "Pidgin" },
        properties = { screen = 1, tag = "4" } },
      { rule = { class = "Firefox" },
        properties = { screen = 2, tag = "1" } },
      { rule = { class = "google-chrome", name = "Hangouts" },
        properties = { screen = 1, tag = "8", sticky = false, ontop=true, border_width = 0 } },
      -- { rule = { class = "google-chrome", role = "pop-up" },
      --   properties = { tag = tags[1][8], sticky = false, ontop=true, border_width = 0 } },

   }

end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if awesome.startup and
       not c.size_hints.user_position
    and not c.size_hints.program_position then
       -- Prevent clients from being unreachable after screen count changes.
       awful.placement.no_offscreen(c)
    end

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
