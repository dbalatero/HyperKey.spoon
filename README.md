# HyperKey.spoon

<img src="https://github.com/dbalatero/HyperKey.spoon/raw/master/images/screenshot.png" />

## Usage

```lua
local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

-- Load and create a new switcher
local HyperKey = hs.loadSpoon("HyperKey")
hyperKey = HyperKey:new(hyper)

-- Bind some applications to keys
hyperKey
  :bind('c'):toApplication('/Applications/Google Chrome.app')
  :bind('s'):toApplication('/Applications/Spotify.app')
  :bind('t'):toApplication('/Applications/Alacritty.app')

-- Bind some functions to keys
local reloadHammerspoon = function()
  hs.application.launchOrFocus("Hammerspoon")
  hs.reload()
end

hyperKey
  :bind('h'):toFunction("Reload Hammerspoon", reloadHammerspoon)
  :bind('l'):toFunction("Lock screen", hs.caffeinate.startScreensaver)
```
