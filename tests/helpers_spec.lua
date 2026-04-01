package.path = './?.lua;' .. package.path

local captured = nil
local geometry = {
  new = function(value)
    if type(value) ~= 'string' then
      return value
    end

    local x, y, w, h = value:match('^(%-?[%d%.]+),(%-?[%d%.]+)%s+([%d%.]+)x([%d%.]+)$')
    if x then
      return {
        x = tonumber(x),
        y = tonumber(y),
        w = tonumber(w),
        h = tonumber(h),
      }
    end

    local gw, gh = value:match('^([%d%.]+)x([%d%.]+)$')
    return {
      w = tonumber(gw),
      h = tonumber(gh),
    }
  end,
  type = function(value)
    if type(value) ~= 'table' then
      return nil
    end

    if value.x ~= nil and value.y ~= nil and value.w ~= nil and value.h ~= nil then
      return 'rect'
    end

    if value.w ~= nil and value.h ~= nil then
      return 'size'
    end

    return nil
  end,
  size = function(x, y)
    return { w = x, h = y }
  end,
}

setmetatable(geometry, {
  __call = function(_, value)
    return geometry.new(value)
  end,
})

hs = {
  spoons = {
    resourcePath = function(name)
      return './' .. name
    end,
  },
  layout = {
    apply = function(elements)
      captured = elements
    end,
  },
  application = {
    open = function() return nil end,
    get = function() return nil end,
  },
  window = {
    visibleWindows = function() return {} end,
    focusedWindow = function()
      return {
        application = function()
          return {
            bundleID = function() return 'term' end,
          }
        end,
      }
    end,
  },
  fnutils = {
    find = function() return nil end,
  },
  geometry = geometry,
  grid = {
    getGridFrame = function()
      return { x = 0, y = 0, w = 600, h = 200 }
    end,
    getGrid = function()
      return { w = 60, h = 20 }
    end,
  },
  screen = {
    find = function() return nil end,
    mainScreen = function()
      return 'MAIN'
    end,
  },
}

package.loaded['hs.grid'] = hs.grid
package.loaded['hs.geometry'] = hs.geometry
package.loaded['hs.screen'] = hs.screen

local helpers = dofile('./helpers.lua')
helpers.grid.getCellWithMargins = function(cell)
  return { raw = cell, x = -1915, y = 592, w = 1910, h = 1070 }
end

local state = {
  current_layout_key = 1,
  current_layout_variant = 1,
  layouts = {
    {
      cells = {
        { '0,0 60x20' },
      },
      apps = {
        Terminal = { cell = 1 },
      },
    },
  },
  apps = {
    Terminal = { id = 'term' },
  },
  layout_customizations = {},
  addLayoutCustomization = function() end,
}

helpers.applyLayout(1, 1, state)

assert(captured ~= nil, 'applyLayout should call hs.layout.apply')
assert(captured[1][5].x == -1915, 'frame coordinates should be passed through unchanged')
assert(captured[1].options.absolute_x == true, 'frame x should be treated as an absolute coordinate')
assert(captured[1].options.absolute_y == true, 'frame y should be treated as an absolute coordinate')

print('helpers_spec ok')
