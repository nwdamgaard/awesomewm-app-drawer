local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local menubar = require("menubar")
local naughty = require("naughty")

local HOME = os.getenv('HOME')
local ICON_DIR = HOME .. '/.config/awesome/awesomewm-app-drawer/'
local DESKTOP_DIR = HOME .. '/Desktop/'

-- the app drawer will be 5 icons wide
local width = 5

-- icons in the app drawer will be 32x32
local icon_size = 32

-- radius for the corners of the buttons and popup window
local border_radius = beautiful.border_radius or 4

-- create a table that contains the .desktop information for every program
local programs_list = { }
awful.spawn.with_line_callback([[bash -c 'find $HOME/Desktop -type f -name "*.desktop"']], {
    stdout = function(line)
        table.insert(programs_list, menubar.utils.parse_desktop_file(line))
    end,
})

local app_drawer_widget = wibox.widget {
    {
        {
            image = ICON_DIR .. 'icon.svg',
            resize = true,
            widget = wibox.widget.imagebox,
        },
        margins = 4,
        layout = wibox.container.margin
    },
    widget = wibox.container.background,
}

local app_drawer = awful.popup {
    ontop = true,
    visible = false,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, border_radius)
    end,
    border_width = 0,
    offset = { x = 5, y = 5 },
    bg = beautiful.fg_normal,
    widget = { }
}

local function generate_drawer()
	local row = { layout = wibox.layout.fixed.horizontal }
	local rows = { layout = wibox.layout.fixed.vertical }
	local width_count = 0
	
	for _, program in pairs(programs_list) do
		
		local icon_widget = wibox.widget {
			{
				{
					image = program.icon_path,
             		forced_height = icon_size,
             		forced_width = icon_size,
                    widget = wibox.widget.imagebox,
				},
				margins = 8,
                layout = wibox.container.margin
			},
			bg = gears.color.transparent,
			shape = function(cr, width, height)
        		gears.shape.rounded_rect(cr, width, height, border_radius)
    		end,
			widget = wibox.container.background,
		}
		
		local icon_container = wibox.widget {
			icon_widget,
			margins = 5,
			layout = wibox.container.margin
		}
		
		icon_widget:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.fg_normal) end)
        icon_widget:connect_signal("mouse::leave", function(c) c:set_bg(gears.color.transparent) end)
		
		icon_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
            awful.spawn(program.cmdline)
            app_drawer.visible = not app_drawer.visible
        end)))
		
		table.insert(row, icon_container)
		
		width_count = width_count + 1
		if width_count == 5 then
			width_count = 0
			table.insert(rows, row)
			row = { layout = wibox.layout.fixed.horizontal }
		end
	end
	
	table.insert(rows, row)
	
	app_drawer:setup(rows)
	
end

local function worker(user_args)
	generate_drawer()

	app_drawer:connect_signal("mouse::leave", function() if app_drawer.visible then
														app_drawer.visible = false
													end
										 end)

	app_drawer_widget:buttons(
            awful.util.table.join(
                    awful.button({}, 1, function()
                        if app_drawer.visible then
                            app_drawer.visible = not app_drawer.visible
                        else
                        	generate_drawer()
                            app_drawer:move_next_to(mouse.current_widget_geometry)
                        end
                    end)
            )
    )

	return app_drawer_widget
end


return setmetatable(app_drawer_widget, { __call = function(_, ...) return worker(...) end })
