# 🌌 ⌨️ HyperKey.spoon

If you have a lot of global key binds to `super`, `hyper`, or other modifier
keys, this [Hammerspoon](https://www.hammerspoon.org/docs/index.html) library lets you easily setup your key binds to switch/launch
applications or call a function.

As well, if you hold down the modifier key(s), a popup help menu will appear
showing you all your key binds:

<img src="https://github.com/dbalatero/HyperKey.spoon/raw/master/images/screenshot.png" />

This was inspired by the Spacemacs [spacebar leader menu](https://www.spacemacs.org/doc/QUICK_START.html#the-leader-keys), and [vim-leader-guide](https://github.com/hecal3/vim-leader-guide).

## Installation

The easiest thing to do is paste this in:

```
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/dbalatero/HyperKey.spoon.git ~/.hammerspoon/Spoons/HyperKey.spoon
```

then move onto the next section for configuration.

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

### Adding a hyper key to OS X

If you don't have a QMK-based keyboard, you can easily add a `hyper` key to
MacOS using Karabiner Elements. There are many tutorials out there; [here's
one](https://brettterpstra.com/2017/06/15/a-hyper-key-with-karabiner-elements-full-instructions/#:~:text=Karabiner%20Elements%20should%20immediately%20detect,%E2%8C%98%E2%87%A7%E2%8C%A5%E2%8C%83X%20)
that might work.

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

## Methods

### `HyperKey:new(modifiers, options)`

Creates a new set of hotkeys triggered by `modifiers`. Holding the `modifiers`
down will show a popup overlay of all registered keybinds.

* `modifiers` - a Lua table of modifiers, e.g. `{'cmd','shift','alt','ctrl'}`
* `options` - a Lua table of options, with the following keys:
  * `overlayTimeoutMs: number` - number of milliseconds to wait before fading in the hotkey overlay. Defaults to `250`ms.

Usage:

```lua
hyperKey = HyperKey:new(
  {'cmd', 'shift', 'alt', 'ctrl'},
  { overlayTimeoutMs = 1000 }
)

-- then bind some keys to it
```

### `HyperKey:bind(displayedKey, [bindKey]):toFunction(name, fn)`

Binds `modifiers` + `bindKey` to a given `fn` to be called.

Returns `self`, so you can chain keybinds.

* `displayedKey` - the key character to display on the popup.
* `bindKey` - the Hammerspoon key to bind. Defaults to `displayedKey`.
  * This is the same set of key values that `hs.hotkey.bind` takes.
* `name` - the description of this key bind to display on the popup.
* `fn` - the function to call when the hotkey is pressed.

Usage:

```lua
local function doSomethingCool()
  -- fill me in
end

hyperKey = HyperKey:new({'cmd', 'shift'})

hyperKey
  :bind('c'):toFunction("Do a cool thing", doSomethingCool)
```

### `HyperKey:bind(displayedKey, [bindKey]):toApplication(applicationPath)`

Binds `modifiers` + `bindKey` to quick-switch to a given application. If the application is not running, it will launch it.

Returns `self`, so you can chain keybinds.

* `displayedKey` - the key character to display on the popup.
* `bindKey` - the Hammerspoon key to bind. Defaults to `displayedKey`.
  * This is the same set of key values that `hs.hotkey.bind` takes.
* `applicationPath` - the application to launch/switch, e.g. `/Applications/Safari.app`

Usage:

```lua
hyperKey = HyperKey:new({'cmd', 'shift'})

hyperKey
  :bind('m'):toApplication('/Applications/Mail.app')
  :bind('s'):toApplication('/Applications/Safari.app')
```
