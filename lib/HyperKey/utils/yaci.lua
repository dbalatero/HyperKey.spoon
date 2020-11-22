-----------------------------------------------------------------------------------
-- Yet Another Class Implementation (version 1.2)
--
-- Julien Patte [julien.patte AT gmail DOT com] - 25 Feb 2007
--
-- Inspired from code written by Kevin Baca, Sam Lie, Christian Lindig and others
-- Thanks to Damian Stewart and Frederic Thomas for their interest and comments
-----------------------------------------------------------------------------------

do	-- keep local things inside

-- associations between an object an its meta-informations
-- e.g its class, its "lower" object (if any), ...
local metaObj = {}
setmetatable(metaObj, {__mode = "k"})

-----------------------------------------------------------------------------------
-- internal function 'duplicate'
-- return a shallow copy of table t

local function duplicate(t)
  t2 = {}
  for k,v in pairs(t) do t2[k] = v end
  return t2
end

-----------------------------------------------------------------------------------
-- internal function 'newInstance'

local function newInstance(class, ...)

  local function makeInstance(class, virtuals)
    local inst = duplicate(virtuals)
    metaObj[inst] = { obj = inst, class = class }

    if class:super()~=nil then
      inst.super = makeInstance(class:super(), virtuals)
      metaObj[inst].super = metaObj[inst.super]	-- meta-info about inst
      metaObj[inst.super].lower = metaObj[inst]
    else
      inst.super = {}
    end

    setmetatable(inst, class.static)

    return inst
  end

  local inst = makeInstance(class, metaObj[class].virtuals)
  inst:init(...)
  return inst
end

-----------------------------------------------------------------------------------
-- internal function 'makeVirtual'

local function makeVirtual(class, fname)
  local func = class.static[fname]
  if func == nil then
    func = function() error("Attempt to call an undefined abstract method '"..fname.."'") end
   end
  metaObj[class].virtuals[fname] = func
end

-----------------------------------------------------------------------------------
-- internal function 'trycast'
-- try to cast an instance into an instance of one of its super- or subclasses

local function tryCast(class, inst)
  local meta = metaObj[inst]
  if meta.class==class then return inst end -- is it already the right class?

  while meta~=nil do	-- search lower in the hierarchy
    if meta.class==class then return meta.obj end
    meta = meta.lower
  end

  meta = metaObj[inst].super  -- not found, search through the superclasses
  while meta~=nil do
    if meta.class==class then return meta.obj end
    meta = meta.super
  end

  return nil -- could not execute casting
end

-----------------------------------------------------------------------------------
-- internal function 'secureCast'
-- same as trycast but raise an error in case of failure

local function secureCast(class, inst)
  local casted = tryCast(class, inst)
  if casted == nil then
	error("Failed to cast " .. tostring(inst) .. " to a " .. class:name())
  end
  return casted
end

-----------------------------------------------------------------------------------
-- internal function 'classMade'

local function classMade(class, obj)
  if metaObj[obj]==nil then return false end -- is this really an object?
  return (tryCast(class,obj) ~= nil) -- check if that class could cast the object
end


-----------------------------------------------------------------------------------
-- internal function 'callup'
-- Function used to transfer a method call from a class to its superclass

local callup_inst
local callup_target

local function callup(inst, ...)
  return callup_target(callup_inst, ...)	-- call the superclass' method
end


-----------------------------------------------------------------------------------
-- internal function 'subclass'

local function inst_init_def(inst,...)
  inst.super:init()
end

local function inst_newindex(inst,key,value)
  if inst.super[key] ~= nil then 	-- First check if this field isn't already
									-- defined higher in the hierarchy
	inst.super[key] = value;		-- Update the old value
  else
  	rawset(inst,key,value); 		-- Create the field
  end
end

local function subclass(baseClass, name)
  if type(name)~="string" then name = "Unnamed" end

  local theClass = {}

	-- need to copy everything here because events can't be found through metatables
  local b = baseClass.static
  local inst_stuff = { __tostring=b.__tostring, __eq=b.__eq, __add=b.__add, __sub=b.__sub,
	__mul=b.__mul, __div=b.__div, __mod=b.__mod, __pow=b.__pow, __unm=b.__unm,
	__len=b.__len, __lt=b.__lt, __le=b.__le, __concat=b.__concat, __call=b.__call}

  inst_stuff.init = inst_init_def
  inst_stuff.__newindex = inst_newindex
  function inst_stuff.class() return theClass end

  function inst_stuff.__index(inst, key) -- Look for field 'key' in instance 'inst'
	local res = inst_stuff[key] 		-- Is it present?
	if res~=nil then return res end		-- Okay, return it

	res = inst.super[key]  				-- Is it somewhere higher in the hierarchy?

	if type(res)=='function' and
		res ~= callup then 				-- If it is a method of the superclass,
		callup_inst = inst.super  		-- we will need to do a special forwarding
		callup_target = res  			-- to call 'res' with the correct 'self'
		return callup 					-- The 'callup' function will do that
	end

	return res
  end


  local class_stuff = { static = inst_stuff, made = classMade, new = newInstance,
	subclass = subclass, virtual = makeVirtual, cast = secureCast, trycast = tryCast }
  metaObj[theClass] = { virtuals = duplicate(metaObj[baseClass].virtuals) }

  function class_stuff.name(class) return name end
  function class_stuff.super(class) return baseClass end
  function class_stuff.inherits(class, other)
	return (baseClass==other or baseClass:inherits(other))
  end

  local function newmethod(class, name, meth)
	inst_stuff[name] = meth;
	if metaObj[class].virtuals[name]~=nil then
		metaObj[class].virtuals[name] = meth
	end
  end

  local function tos() return ("class "..name) end
  setmetatable(theClass, { __newindex = newmethod, __index = class_stuff,
	__tostring = tos, __call = newInstance } )

  return theClass
end

-----------------------------------------------------------------------------------
-- The 'Object' class

local Object = {}

local function obj_newitem() error "May not modify the class 'Object'. Subclass it instead." end
local obj_inst_stuff = {}
function obj_inst_stuff.init(inst,...) end
obj_inst_stuff.__index = obj_inst_stuff
obj_inst_stuff.__newindex = obj_newitem
function obj_inst_stuff.class() return Object end
function obj_inst_stuff.__tostring(inst) return ("a "..inst:class():name()) end

local obj_class_stuff = { static = obj_inst_stuff, made = classMade, new = newInstance,
	subclass = subclass, cast = secureCast, trycast = tryCast }
function obj_class_stuff.name(class) return "Object" end
function obj_class_stuff.super(class) return nil end
function obj_class_stuff.inherits(class, other) return false end
metaObj[Object] = { virtuals={} }

local function tos() return ("class Object") end
setmetatable(Object, { __newindex = obj_newitem, __index = obj_class_stuff,
	__tostring = tos, __call = newInstance } )

----------------------------------------------------------------------
-- function 'newclass'

local function newclass(name, baseClass)
 baseClass = baseClass or Object
 return baseClass:subclass(name)
end

return newclass
end -- 2 global things remain: 'Object' and 'newclass'

-- end of code
