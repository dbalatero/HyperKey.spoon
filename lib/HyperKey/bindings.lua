local newclass = require('HyperKey.utils.yaci')

local KeyBinding = newclass("KeyBinding")

function KeyBinding:init(name)
  self.name = name
end

function KeyBinding:launch()
  error "Subclass this method instead."
end

------

local ApplicationBinding = KeyBinding:subclass("ApplicationBinding")

function ApplicationBinding:init(applicationPath)
  local parts = hs.fnutils.split(applicationPath, "/")
  local name = parts[#parts]

  local nameParts = hs.fnutils.split(name, ".", nil, true)
  local basename = nameParts[1]

  self.super:init(basename)
  self.applicationPath = applicationPath
end

function ApplicationBinding:launch()
  hs.application.launchOrFocus(self.applicationPath)
end

------

local FunctionBinding = KeyBinding:subclass('FunctionBinding')

function FunctionBinding:init(name, fn)
  self.super:init(name)
  self.fn = fn
end

function FunctionBinding:launch()
  self.fn()
end

------

return {
  ApplicationBinding = ApplicationBinding,
  FunctionBinding = FunctionBinding,
}
