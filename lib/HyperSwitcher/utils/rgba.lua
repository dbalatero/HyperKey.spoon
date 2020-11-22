local function rgba(r, g, b, a)
  a = a or 1.0

  return {
    red = r / 255,
    green = g / 255,
    blue = b / 255,
    alpha = a
  }
end

return rgba
