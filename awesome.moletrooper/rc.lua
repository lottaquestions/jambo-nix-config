--[[

     Awesome WM configuration template
     github.com/lcpz

--]]
-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local charitable = require("charitable")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors
        }
    )
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function(err)
            if in_error then
                return
            end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end
-- }}}

-- {{{ Variable definitions
-- global so they can be used in keybinds.lua
modkey = "Mod4"
altkey = "Mod1"
terminal = "kitty"
editor = os.getenv("EDITOR") or "vim"
gui_editor = "code"
browser = "firefox"
guieditor = "code"

awful.util.terminal = terminal
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    -- awful.layout.suit.fair
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- lain.layout.cascade,
    -- lain.layout.cascade.tile,
    -- lain.layout.centerwork,
    -- lain.layout.centerwork.horizontal,
    -- lain.layout.termfair,
    -- lain.layout.termfair.center
}
awful.layout.tags =
    charitable.create_tags(
    {"1", "2", "3", "4", "5", "6"},
    {
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[2],
        awful.layout.layouts[2],
        awful.layout.layouts[3],
    }
)

awful.util.taglist_buttons =
    my_table.join(
    awful.button(
        {},
        1,
        function(t)
            charitable.select_tag(t, awful.screen.focused())
        end
    ),
    awful.button(
        {},
        3,
        function(t)
            charitable.toggle_tag(t, awful.screen.focused())
        end
    )
)

awful.util.tasklist_buttons =
    my_table.join(
    awful.button(
        {},
        1,
        function(c)
            if c == client.focus then
                c.minimized = true
            else
                --c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end
    ),
    awful.button(
        {},
        2,
        function(c)
            c:kill()
        end
    ),
    awful.button(
        {},
        3,
        function()
            local instance = nil

            return function()
                if instance and instance.wibox.visible then
                    instance:hide()
                    instance = nil
                else
                    instance = awful.menu.clients({theme = {width = dpi(250)}})
                end
            end
        end
    )
)

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

beautiful.init(string.format("%s/.config/awesome/theme/theme.lua", os.getenv("HOME")))

-- }}}

-- {{{ Random wallpaper

local random_wallpaper = require("random-wallpaper")
function wallpaper(screen)
    local wp = random_wallpaper(screen)
    local msg = wp == nil and "No wallpaper found" or string.match(wp, "[^/]+$")
    naughty.notify(
        {
            title = "Wallpaper",
            text = msg,
            screen = screen,
            position = "bottom_right",
            timeout = 5
        }
    )
    return wp
end

-- swap wallpapers on a timer
local wp_timer = gears.timer {
    timeout = 5 * 60,
    call_now = true,
    autostart = true,
    callback = function()
        for s in screen do
            local wp = wallpaper(s)
            if wp ~= nil then
                gears.wallpaper.maximized(wp, s)
            end
        end
    end
}

function toggle_slideshow(screen)
    if wp_timer.started then
        wp_timer:stop()
        naughty.notify(
            {
                text = "Stopped wallpaper slideshow",
                screen = screen,
                position = "bottom_right",
                timeout = 1
            }
        )
    else
        -- immediately change the wallpaper
        wp_timer:emit_signal("timeout")
        wp_timer:start()
    end
end

-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal(
    "property::geometry",
    function(s)
        -- Wallpaper
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end
)

-- No borders when maximized
screen.connect_signal(
    "arrange",
    function(s)
        for _, c in pairs(s.clients) do
            if c.maximized then
                c.border_width = 0
            else
                c.border_width = beautiful.border_width
            end
        end
    end
)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(
    function(s)
        beautiful.at_screen_connect(s)
    end
)
-- }}}

-- padding controls
function increment_padding(amount)
    local scr = awful.screen.focused()
    local curr_padding = scr.padding.left
    local new_padding = curr_padding + amount
    if new_padding < 0 then
        new_padding = 0
    end
    scr.padding = {
        left = new_padding,
        right = new_padding,
        top = new_padding,
        bottom = new_padding,
    }
    awful.layout.arrange(scr)
end
-- set initial padding from env vars if available
awful.screen.connect_for_each_screen(
    function(s)
        local p = 0
        for k,v in pairs(s.outputs) do
            local varname = "AWESOME_PADDING_" .. k:gsub("-", "_")
            local fromenv = tonumber(os.getenv(varname))
            if fromenv ~= nil then
                p = fromenv
            end
        end
        s.padding = {
            left = p,
            right = p,
            top = p,
            bottom = p,
        }
    end
)

-- {{{ key bindings from another file
local globalkeys, clientkeys, clientbuttons = require("keybinds")()

root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            size_hints_honor = false,
            titlebars_enabled = false,
            maximized = false,
            maximized_vertical = false,
            maximized_horizontal = false
        },
    },
    -- Titlebars
    {
        rule_any = { type = {"dialog"} },
        properties = { titlebars_enabled = true }
    },
    {
        rule = { floating = true },
        properties = { titlebars_enabled = true },
    },
    {
        rule_any = { class = { "pinentry" } },
        properties = { floating = true },
    },
    {
        -- I set this class on games I make, those should be floating by default
        rule_any = { class = { "game" } },
        properties = { floating = true },
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
    "manage",
    function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        if not awesome.startup then
            awful.client.setslave(c)
        end

        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end

        if not c.fullscreen then
            c.shape = function(cr, w, h)
                gears.shape.octogon(cr, w, h, 10)
            end
        end

        if c.floating then
            awful.titlebar.show(c)
        else
            awful.titlebar.hide(c)
        end
    end
)

-- show a titlebar when a window is made floating after creation
client.connect_signal(
    "property::floating",
    function(c)
        if c.floating then
            awful.titlebar.show(c)
        else
            awful.titlebar.hide(c)
        end
    end
)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
    "request::titlebars",
    function(c)
        -- Custom
        if beautiful.titlebar_fun then
            beautiful.titlebar_fun(c)
            return
        end

        -- Default
        -- buttons for the titlebar
        local buttons =
            my_table.join(
            awful.button(
                {},
                1,
                function()
                    c:emit_signal("request::activate", "titlebar", {raise = true})
                    awful.mouse.client.move(c)
                end
            ),
            awful.button(
                {},
                2,
                function()
                    c:kill()
                end
            ),
            awful.button(
                {},
                3,
                function()
                    c:emit_signal("request::activate", "titlebar", {raise = true})
                    awful.mouse.client.resize(c)
                end
            )
        )

        awful.titlebar(c, {size = dpi(16)}):setup {
            {
                -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal
            },
            {
                -- Middle
                {
                    -- Title
                    align = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout = wibox.layout.flex.horizontal
            },
            {
                -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end
)

client.connect_signal(
    "focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)
client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)

-- possible workaround for tag preservation when switching back to default screen:
-- https://github.com/lcpz/awesome-copycats/issues/251
-- }}}

-- Charitable: ensure that removing screens doesn't kill tags
tag.connect_signal(
    "request::screen",
    function(t)
        t.selected = false
        for s in capi.screen do
            if s ~= t.screen then
                t.screen = s
                return
            end
        end
    end
)
-- Charitable: work around bugs in awesome 4.0 through 4.3+
-- see https://github.com/awesomeWM/awesome/issues/2780
awful.tag.history.restore = function()
end
