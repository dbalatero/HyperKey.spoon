-- Setup load paths.
local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local rootDir = scriptPath()
package.path = rootDir .. "lib/?.lua;" .. package.path

-----------------------------------------

local newclass = require('HyperSwitcher.utils.yaci')
local onModifierHold = require('HyperSwitcher.utils.on_modifier_hold')
local bindings = require('HyperSwitcher.bindings')
local Overlay = require('HyperSwitcher.overlay')

----------------------------------------------------------------

local HyperSwitcher = newclass("HyperSwitcher")

function HyperSwitcher:init(hyperMods, options)
  options = options or {}

  self.overlayTimeoutMs = options.overlayTimeoutMs or 250
  self.hyperMods = hyperMods
  self.bindings = {}
  self.overlay = Overlay:new(self.bindings)
  self.holdTap = self:_createOverlayTap()
end

function HyperSwitcher:bind(displayedKey, bindKey)
  bindKey = bindKey or displayedKey

  return {
    toApplication = function(_, applicationName)
      return self:_bind(
        displayedKey,
        bindKey,
        bindings.ApplicationBinding:new(applicationName)
      )
    end,
    toFunction = function(_, name, fn)
      return self:_bind(
        displayedKey,
        bindKey,
        bindings.FunctionBinding:new(name, fn)
      )
    end
  }
end

function HyperSwitcher:_bind(key, bindKey, binding)
  table.insert(self.bindings, {
    key = key,
    bindKey = bindKey,
    binding = binding
  })

  self.overlay = Overlay:new(self.bindings)

  hs.hotkey.bind(self.hyperMods, bindKey, function()
    binding:launch()
  end)

  return self
end

function HyperSwitcher:_createOverlayTap()
  local onHold = function()
    self.overlay:show()
  end

  local onRelease = function()
    self.overlay:hide()
  end

  return onModifierHold(self.hyperMods, self.overlayTimeoutMs, onHold, onRelease)
end

return HyperSwitcher
