-- Setup load paths.
local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local rootDir = scriptPath()
package.path = rootDir .. "lib/?.lua;" .. package.path

-----------------------------------------

local newclass = require('HyperKey.utils.yaci')
local onModifierHold = require('HyperKey.utils.on_modifier_hold')
local bindings = require('HyperKey.bindings')
local Overlay = require('HyperKey.overlay')

----------------------------------------------------------------

local HyperKey = newclass("HyperKey")

HyperKey.author = "David Balatero <d@balatero.com>"
HyperKey.homepage = "https://github.com/dbalatero/HyperKey.spoon"
HyperKey.license = "MIT"
HyperKey.name = "HyperKey"
HyperKey.version = "1.0.0"
HyperKey.spoonPath = rootDir

function HyperKey:init(hyperMods, options)
  options = options or {}

  self.overlayTimeoutMs = options.overlayTimeoutMs or 250
  self.hyperMods = hyperMods
  self.bindings = {}
  self.overlay = Overlay:new(self.bindings)
  self.holdTap = self:_createOverlayTap()
end

function HyperKey:bind(displayedKey, bindKey)
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

function HyperKey:_bind(key, bindKey, binding)
  table.insert(self.bindings, {
    key = string.upper(key),
    bindKey = bindKey,
    binding = binding
  })

  self.overlay = Overlay:new(self.bindings)

  hs.hotkey.bind(self.hyperMods, bindKey, function()
    binding:launch()
  end)

  return self
end

function HyperKey:_createOverlayTap()
  local onHold = function()
    self.overlay:show()
  end

  local onRelease = function()
    self.overlay:hide()
  end

  return onModifierHold(self.hyperMods, self.overlayTimeoutMs, onHold, onRelease)
end

return HyperKey
