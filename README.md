# HyperKey.spoon

If you have a lot of global key binds to `super`, `hyper`, or other modifier keys, this library lets you easily setup your key binds to switch/launch applications or call a function.

As well, if you hold down the modifier key(s), a popup help menu will appear showing you all your key binds:

<img src="https://github.com/dbalatero/HyperKey.spoon/raw/master/images/screenshot.png" />

This was inspired by the Spacemacs [spacebar leader menu](https://www.spacemacs.org/doc/QUICK_START.html#the-leader-keys), and [vim-leader-guide](https://github.com/hecal3/vim-leader-guide).

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

### Controlling the popup delay

The popup delay defaults to `250ms`. You can control this with an option:

```lua
local hyper = {'cmd', 'alt', 'ctrl', 'shift'}

hyperKey = HyperKey:new(hyper, {
  overlayTimeoutMs = 1000, -- wait 1000ms instead
})
```

### Multiple popup menus

Having different menus for different modifiers is easy - just create an object for each set of modifier keys:

```lua
hyperKey = HyperKey:new({'cmd', 'alt', 'ctrl', 'shift'})
hyperKey:bind('s'):toApplication('/Applications/Safari.app')

superKey = HyperKey:new({'cmd', 'alt', 'ctrl'})
superKey:bind('L'):toFunction('Lock screen', hs.caffeinate.startScreensaver)
```
