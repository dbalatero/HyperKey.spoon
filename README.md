# HyperSwitcher.spoon

## Usage

```lua
local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

-- Load and create a new switcher
local HyperSwitcher = hs.loadSpoon("HyperSwitcher")
hyperSwitcher = HyperSwitcher:new(hyper)

-- Bind some applications to keys
hyperSwitcher
  :bind('c'):toApplication('/Applications/Google Chrome.app')
  :bind('s'):toApplication('/Applications/Spotify.app')
  :bind('t'):toApplication('/Applications/Alacritty.app')

-- Bind some functions to keys
local reloadHammerspoon = function()
  hs.application.launchOrFocus("Hammerspoon")
  hs.reload()
end

hyperSwitcher
  :bind('h'):toFunction("Reload Hammerspoon", reloadHammerspoon)
  :bind('l'):toFunction("Lock screen", hs.caffeinate.startScreensaver)
```
