# App-Drawer
A minimalistic app drawer for awesomewm. Uses .desktop format.

# Installation
Clone this git repo into your ~/.config/awesome folder:
```git clone https://github.com/nwdamgaard/awesomewm-app-drawer.git```

# Usage
1. Add ```local app_drawer_widget = require("app-drawer.drawer")``` to your rc.lua file. NOTE: this **must** be placed after the ```beautiful.init``` line.
2. Use ```app_drawer_widget()``` to create the widget. I have mine in my top bar.

# Config
- You can change the size of the icons by changing the ```icon_size``` variable in drawer.lua. Default is 32px.
- You can change how many icons wide the widget will be before making a new row by changing ```width``` in drawer.lua. Default is 5 icons wide.
- You can change what folder to look for .desktop files in by changing the ```DESKTOP_DIR``` variable in drawer.lua. Default is ~/Desktop.
