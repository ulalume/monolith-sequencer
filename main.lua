package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local json = require "rxi-json-lua"

local color = require "graphics.color"
local Rainbow = require "graphics.rainbow"
local rainbow = Rainbow:new(1 / 20, { color.black, color.white })

local monolith = require "monolith.core".new({ ledColorBits = 3 })

local musicSystem
local soundChanger
local board = {
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 1, -1, 0, 0, 0,
  0, 0, 0, -1, 1, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
}
local cursorX = 0
local cursorY = 0

local operationTimer = require "util.timer":new(3, 1)

local function x_m()
  cursorX = math.max(0, cursorX - 1)
end

local function x_p()
  cursorX = math.min(7, cursorX + 1)
end

local function y_m()
  cursorY = math.max(0, cursorY - 1)
end

local function y_p()
  cursorY = math.min(7, cursorY + 1)
end

local cursorMove = { { x_m, x_p, y_m, y_p }, { x_p, x_m, y_p, y_m }, { y_p, y_m, x_m, x_p }, { y_m, y_p, x_p, x_m } }


local client

local function newConnection()
  client = require "websocket".new("127.0.0.1", 5001, "/")
  function client:onmessage(message)
    print(message)
    local b = json.decode(message)
    if #b == 64 then
      board = b
    end
  end

  function client:onerror(error)
    print("error: " .. error)
    client:close()
    client.socket:close()
    newConnection()
  end

  function client:onopen()
    self:send("client connect")
  end

  function client:onclose(code, reason)
    print("closecode: " .. code .. ", reason: " .. reason)
  end
end

local img1, img2
function love.load()
  img1 = love.graphics.newImage("assets/image/check.png")
  img2 = love.graphics.newImage("assets/image/circle.png")

  if require "util.osname" == "Linux" then
    for i, inp in ipairs(require "config.linux_input_settings") do monolith.input:setUserSetting(i, inp) end
  else
    for i, inp in ipairs(require "config.input_settings") do monolith.input:setUserSetting(i, inp) end
  end

  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')

  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require("music.music_system"):new({ true, true, true, true }, devices, musicPathTable, priorityTable)
  soundChanger = require "sound-changer":new(musicSystem)

  musicSystem:playAllPlayer("bgm")

  newConnection()
end

function love.update(dt)
  client:update()
  musicSystem:update(dt)
  soundChanger:update(dt)
  operationTimer:executable(dt)

  for i = 1, 4 do
    if monolith.input:getButtonDown(i, "a") then
      local stone = board[cursorX + cursorY * 8 + 1]
      if stone == -1 then
        stone = 0
      else
        stone = -1
      end
      board[cursorX + cursorY * 8 + 1] = stone
      operationTimer:reset()
    end
    if monolith.input:getButtonDown(i, "b") then
      local stone = board[cursorX + cursorY * 8 + 1]
      if stone == 1 then
        stone = 0
      else
        stone = 1
      end
      board[cursorX + cursorY * 8 + 1] = stone
      operationTimer:reset()
    end
  end

  -- 配置
  --   2P
  -- 4P  3P
  --   1P
  for i = 1, 4 do
    if monolith.input:getButtonDown(i, "left") then
      cursorMove[i][1]()
      operationTimer:reset()
    elseif monolith.input:getButtonDown(i, "right") then
      cursorMove[i][2]()
      operationTimer:reset()
    end
    if monolith.input:getButtonDown(i, "up") then
      cursorMove[i][3]()
      operationTimer:reset()
    elseif monolith.input:getButtonDown(i, "down") then
      cursorMove[i][4]()
      operationTimer:reset()
    end
  end

  -- 2個ずつ取得
  for i = 1, #board / 2 do
    local v1 = (board[i * 2 - 1] + 1) * 3
    local v2 = (board[i * 2] + 1)
    local v = math.min(math.ceil(((v1 + v2) / 8) * 128), 127)

    soundChanger:setSoundControl(i, v)
  end
  local s = ""
  for i = 1, #soundChanger.changing do
    s = s .. ", " .. soundChanger.changing[i]
  end
end

function love.draw()
  monolith:beginDraw()
  love.graphics.setColor(1, 1, 1)
  for i = 1, #board do
    local stone = board[i]
    local x = (i - 1) % 8
    local y = (i - 1 - x) / 8
    if stone ~= 0 then
      if stone == -1 then
        love.graphics.draw(img1, x * 16, y * 16)
      end
      if stone == 1 then
        love.graphics.draw(img2, x * 16, y * 16)
      end
    end
    love.graphics.rectangle("line", x * 16, y * 16, 16, 16)
  end

  if not operationTimer:isLimit() then
    love.graphics.setColor(rainbow:color():rgb())
    love.graphics.rectangle("line", cursorX * 16, cursorY * 16, 16, 16)
  end

  monolith:endDraw()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(tostring(love.timer.getFPS()), 0, 0)
end

function love.quit()
  musicSystem:gc()
  if require "util.osname" == "Linux" then
    require "util.open_launcher" ()
  end
end
