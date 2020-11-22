local function onModifierHold(modifiers, timeoutMs, onHold, onRelease)
  local state = {
    held = false,
    holdTimer = nil,
    onHold = onHold,
    onRelease = onRelease,
  }

  local cancelTimer = function()
    if not state.holdTimer then return end

    state.holdTimer:stop()
    state.holdTimer = nil
  end

  state.tap = hs.eventtap.new(
    {
      hs.eventtap.event.types.flagsChanged,
    },
    function(event)
      local type = event:getType()
      local containsFlags = event:getFlags():containExactly(modifiers)

      if state.held then
        -- waiting for a release
        if not containsFlags then
          state.held = false
          onRelease()
          cancelTimer()
        end
      elseif state.holdTimer then
        -- we are waiting for the timeout timer to fire
        if not containsFlags then
          cancelTimer()
        end
      elseif containsFlags then
        state.holdTimer = hs.timer.doAfter(timeoutMs / 1000, function()
          state.held = true
          onHold()
        end)
      end

      return false
    end
  )

  state.tap:start()

  return state
end

return onModifierHold
