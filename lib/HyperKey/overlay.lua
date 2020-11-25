local newclass = require('HyperKey.utils.yaci')
local rgba = require('HyperKey.utils.rgba')

local Overlay = newclass('Overlay')

local fadeTime = 150 / 1000

function Overlay:init(bindings)
  self.bindings = bindings
  self.canvas = nil
end

function Overlay:show()
  self.canvas = self:_buildCanvas()
  self.canvas:show(fadeTime)
end

function Overlay:hide()
  self.canvas:delete(fadeTime)
  self.canvas = nil
end

function Overlay:_buildCanvas()
  local layerIndexes = {
    background = 1,
    keyIndex = 2,
  }

  table.sort(self.bindings, function(a, b)
    return a.key < b.key
  end)

  -- how much padding around the edges
  local containerPadding = 25

  local itemsPerColumn = 6
  local itemHeight = 25
  local itemBottomMargin = 10
  local itemContainer = itemHeight + itemBottomMargin

  local columnWidth = 275
  local columnCount = math.ceil(#self.bindings / itemsPerColumn)

  local defaultWidth = (containerPadding * 2) + (columnCount * columnWidth)
  local defaultHeight = (containerPadding * 2) + (itemsPerColumn * itemContainer) - itemBottomMargin

  local canvas = hs.canvas.new{
    w = defaultWidth,
    h = defaultHeight,
    x = 100,
    y = 100,
  }

  -- show in center
  local frame = hs.screen.mainScreen():frame()

  canvas:level("overlay")
  canvas:topLeft({
    x = (frame.w / 2) - (defaultWidth / 2),
    y = (frame.h / 2) - (defaultHeight / 2),
  })

  -- render the background rectangle
  canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      roundedRectRadii = { xRadius = 10, yRadius = 10 },
      fillColor = rgba(24, 135, 250, 1),
      strokeColor = { white = 1.0 },
      strokeWidth = 3.0,
      frame = { x = "0%", y = "0%", h = "100%", w = "100%", },
    },
    layerIndexes.background
  )

  local currentLayerIndex = layerIndexes.keyIndex

  for index, entry in pairs(self.bindings) do
    local zeroIndex = index - 1

    local keySize = 25
    local keyRightMargin = 10

    local columnIndex = math.floor(zeroIndex / itemsPerColumn)

    local startX = containerPadding + (columnIndex * columnWidth)
    local startY = containerPadding + ((zeroIndex % itemsPerColumn) * itemContainer)

    canvas:insertElement(
      {
        type = 'rectangle',
        action = 'fill',
        roundedRectRadii = { xRadius = 5, yRadius = 5 },
        fillColor = rgba(255, 255, 255, 1.0),
        frame = {
          x = startX,
          y = startY,
          w = keySize,
          h = keySize,
        },
        withShadow = true,
        shadow = {
          blurRadius = 5.0,
          color = { alpha = 1/3 },
          offset = { h = -2.0, w = 2.0 },
        }
      },
      currentLayerIndex
    )

    currentLayerIndex = currentLayerIndex + 1

    canvas:insertElement(
      {
        type = 'text',
        text = entry.key,
        action = 'fill',
        frame = {
          x = startX,
          y = startY + 3,
          h = keySize,
          w = keySize,
        },
        textAlignment = "center",
        textColor = rgba(38, 38, 38, 1.0),
        textFont = "Helvetica Bold",
        textSize = 14,
      },
      currentLayerIndex
    )

    currentLayerIndex = currentLayerIndex + 1

    canvas:insertElement(
      {
        type = 'text',
        text = hs.styledtext.new(
          entry.binding.name,
          {
            font = { name = "Helvetica Neue", size = 16 },
            color = rgba(255, 255, 255, 1.0),
            kerning = 1.2,
            shadow = {
              blurRadius = 10,
            }
          }
        ),
        action = 'fill',
        frame = {
          x = startX + keySize + keyRightMargin,
          y = startY,
          h = keySize,
          w = 300,
        },
      },
      currentLayerIndex
    )

    currentLayerIndex = currentLayerIndex + 1
  end

  return canvas
end

return Overlay
