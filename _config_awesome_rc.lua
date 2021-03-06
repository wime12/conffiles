-- Find our virtual terminal
vtfd = io.popen("/home/wilfried/.local/libexec/chvt")
local virtual_terminal

if vtfd then
  virtual_terminal = vtfd:read("*l")
end

vtfd:close()

-- Get Display Number

display_string=os.getenv("DISPLAY")

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
require("sysctl")

-- get cache directory
local xdg_cache_dir=awful.util.getdir("cache")

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/wilfried/.themes/awesome-theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
--    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
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
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create the mailbox widget
mymailbox = wibox.widget.textbox()

-- Create the battery widget
mybatterywidget = wibox.widget.textbox()

-- Create the keyboard widget
mykeyboardwidget = wibox.widget.textbox()

-- Create the panning widget
mypanningwidget = wibox.widget.textbox()

-- Create the volume widget
myvolumewidget = wibox.widget.textbox()

-- Create the net widget
mynetwidget = wibox.widget.textbox()

-- Create the weather widget
myweatherwidget = wibox.widget.textbox()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
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
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(myweatherwidget)
    right_layout:add(mymailbox)
    right_layout:add(mynetwidget)
    right_layout:add(myvolumewidget)
    right_layout:add(mybatterywidget)
    right_layout:add(mykeyboardwidget)
    right_layout:add(mytextclock)
    right_layout:add(mypanningwidget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
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
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    -- Keyboard
    awful.key({ modkey }, ".", function() switch_kbd() end)
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
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
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
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
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

-- Mailbox

function mailcheck()
  local file = io.popen("mail -H", "r")
  if file then
    local new_mail
    local unread_mail
    local line = file:read("*l")
    if line then
      line = file:read("*l")
    else
      line = ""
    end
    file:close()
    if line then
      new_mail = string.match(line, "(%d+) new")
      unread_mail = string.match(line, "(%d+) unread")
    end
    if (new_mail and tonumber(new_mail) > 0) then
      mymailbox:set_markup(" <span foreground=\"red\" rise='500' font_size=\"17000\" font_weight=\"bold\">✉</span>")
    elseif (unread_mail and tonumber(unread_mail) > 0) then
      mymailbox:set_markup(" <span foreground=\"yellow\" rise='500' font_size=\"17000\">✉</span>")
    else
      mymailbox:set_text("")
    end
  end
end

mailcheck()

-- Utility Functions

function bar_symbol(n)
    if     n <= 12 then return "▁"
    elseif n <= 25 then return "▂"
    elseif n <= 37 then return "▃"
    elseif n <= 50 then return "▄"
    elseif n <= 62 then return "▅"
    elseif n <= 75 then return "▆"
    elseif n <= 87 then return "▇"
    else                return "█"
    end
end

function symbol_color(n)
    if     n <= 12 then return "red"
    elseif n <= 25 then return "yellow"
    else                return "lightgreen"
    end
end


-- Battery

function show_battery_state()
  local life = sysctl.get("hw.acpi.battery.life")
  local state = sysctl.get("hw.acpi.battery.state")
  local time = sysctl.get("hw.acpi.battery.time")
  local state_symbol, battery_symbol, color
  if state == 2 then
    state_symbol = "↑"
  elseif state == 1 then
    state_symbol = "↓"
  else state_symbol = ""
  end
  mybatterywidget:set_markup(" <span rise='1500' foreground='" ..
			      symbol_color(life) ..
			      "'>" ..
			      bar_symbol(life) .. state_symbol ..
			      "</span>")
end

show_battery_state()

battery_timer = timer({ timeout = 10 })
battery_timer:connect_signal("timeout", function()
  show_battery_state()
end)
battery_timer:start()

-- Keyboard

kbd_state = 0
function switch_kbd()
    if kbd_state == 1 then
	os.execute("/usr/local/bin/setxkbmap de T3 -option compose:menu")
	mykeyboardwidget:set_markup(" <span font_weight=\"bold\">DE</span>")
	kbd_state = 0
    else
	os.execute("/usr/local/bin/setxkbmap us -option compose:menu")
	mykeyboardwidget:set_markup(" <span font_weight=\"bold\">US</span>")
	kbd_state = 1
    end
end

switch_kbd()

-- Panning

local panning_file_name = xdg_cache_dir.."/awesome-panning-vt"..virtual_terminal
local panning_state = 0

local panning_file = io.open(panning_file_name)
if panning_file then
    panning_state = panning_file:read("*l")
    panning_file:close()
    if panning_state then
	panning_state = tonumber(panning_state)
	if panning_state < 0 and panning_state > 2 then
	    panning_state = 0
	end
    end
end

function set_panning(n)
  if n == 0 then
    os.execute("xrandr --output LVDS1 --mode 1024x600 --panning 1024x600 --scale 1x1")
  elseif n == 1 then
    -- os.execute("xrandr --output LVDS1 --fb 1024x768 --mode 1024x600 --panning 1024x768 --scale 1x1.28")
    os.execute("xrandr --output LVDS1 --fb 1311x768 --mode 1024x600 --panning 1311x768 --scale 1.28x1.28")
  else
    os.execute("xrandr --output LVDS1 --mode 1024x600 --panning 1024x768 --scale 1x1")
  end
end

function display_panning(n)
    local panning_symbol
    if n == 0 then
	-- panning_symbol = "☐"
	panning_symbol = nil
    elseif n == 1 then
        -- panning_symbol = "↨"
        panning_symbol = "T"
    else
        -- panning_symbol = "↡"
        panning_symbol = "P"
    end
    if panning_symbol then
	mypanningwidget:set_markup("<span font_weight='bold'>"..panning_symbol.." </span>")
    else
	mypanningwidget:set_text("")
    end
end

function cycle_panning(vt)
  if tonumber(vt) ~= tonumber(virtual_terminal) then return end
  panning_state = (panning_state + 1) % 3
  set_panning(panning_state)
  display_panning(panning_state)
  panning_file = io.open(panning_file_name, "w")
  if panning_file then
    panning_file:write(tostring(panning_state))
    panning_file:close()
  end
end

set_panning(panning_state)
display_panning(panning_state)

-- Volume

function update_volume()
    local volume_file = io.popen("mixer -s vol")
    local volume_string
    if volume_file then
	volume_string = volume_file:read("*l")
	volume_file:close()
    end
    local left, right = string.match(volume_string, "vol (%d+):(%d+)")
    left = tonumber(left)
    right = tonumber(right)
    myvolumewidget:set_markup(" <span rise='1500'" ..
			      ((left == 100) and " color='white'" or "") ..
			      ">" ..
			      ((left > 0) and bar_symbol(left) or "☒") ..
			      "</span><span rise='1500'" ..
			      ((right == 100) and " color='white'" or "") ..
			      ">" ..
			      ((right > 0) and bar_symbol(right) or "☒") ..
			      "</span> ")
end

update_volume()

volume_timer = timer({ timeout = 10 })
volume_timer:connect_signal("timeout", function()
  update_volume()
end)
volume_timer:start()

-- Net

function show_net_state()
    local file = io.popen("ifconfig lagg0")
    local active_interface
    if file then
        local line = file:read("*l")
	while line and not active_interface do
	    active_interface = string.match(line, "laggport: (%w+) .*ACTIVE.*")
	    line = file:read("*l")
	end
	file:close()
    end
    if active_interface == "alc0" then
	state_symbol = "⚉"
    elseif active_interface == "wlan0" then
	state_symbol = "★"
    else
	state_symbol = "⛌"
    end
    mynetwidget:set_markup(" <span rise='1000' font_size='13000'>"..state_symbol.."</span>")
end

show_net_state()

-- Start Monitor

local monitor_pid_file="/home/wilfried/.awesome-monitor-"..display_string..".pid"
os.execute("/usr/sbin/daemon -P "..monitor_pid_file.." /home/wilfried/.local/libexec/awesome-monitor")

awesome.connect_signal("exit", function()
  local file = io.open(monitor_pid_file, "r")
  local pgid
  if file then pgid = file:read("*l") end
  os.execute("/bin/kill -- -"..pgid)
end)
