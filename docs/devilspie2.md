# devilspie2

**window matching utility**

You can use `devilspie2` to open windows on specific desktops, define placement, and window features like maximized, or fullscreen. You can setup complex window layouts this way even create a "per window" tiling manager if you want. Export your layouts and you can script or hotkey the launch and arrangement of your windows.

**Run as systemd user service:**

`mkdir -p ~/.config/systemd/user/`

```
echo "[Unit]
Description=Devilspie2 window matching utility

[Service]
ExecStart=/usr/bin/devilspie2

[Install]
WantedBy=default.target" > ~/.config/systemd/user/devilspie2.service
```
`systemctl --user enable devilspie2`  `systemctl --user start devilspie2`

`mkdir -p ~/.config/devilspie2`

```
echo "debug_print( "Window Name: "..	get_window_name());
debug_print( "Application Name: "..get_application_name())" > .config/devilspie2/devilspie2.lua
```

## Complete Debug

```
debug_print( "get_window_name:                      " .. get_window_name())
debug_print( "get_application_name:                 " .. get_application_name())
debug_print( "get_window_geometry:                  " .. get_window_geometry())
debug_print( "get_window_client_geometry:           " .. get_window_client_geometry())
debug_print( "get_window_type:                      " .. get_window_type())
debug_print( "get_class_instance_name:              " .. get_class_instance_name())
debug_print( "get_window_role:                      " .. get_window_role())
debug_print( "get_window_xid:                       " .. get_window_xid())
debug_print( "get_window_class:                     " .. get_window_class())
debug_print( "get_workspace_count:                  " .. get_workspace_count())
screen_x, screen_y = get_screen_geometry()
debug_print( "get_screen_geometry                   " .. screen_x .. "x" .. screen_y )
window_x, window_y, window_w, window_h = xywh()
debug_print( "xywh:                                 " .. window_x .. "," .. window_y .."+" .. window_w .. "+" .. window_h )
-- debug_print( "get_screen_geometry:                  " .. get_screen_geometry())
-- debug_print( "get_window_has_name:                  " .. get_window_has_name())
-- debug_print( "get_window_is_maximized:              " .. get_window_is_maximized())
-- debug_print( "get_window_is_maximized_vertically:   " .. get_window_is_maximized_vertically())
-- debug_print( "get_window_is_maximized_horizontally: " .. get_window_is_maximized_horizontally())
-- debug_print( "get_window_property:                  " .. get_window_property())
-- debug_print( "get_window_fullscreen:                " .. get_window_fullscreen())
debug_print( "\n" )
```

Start profiling applications: `devilspie2 --folder ~/.config/devilspie2/ --debug`
