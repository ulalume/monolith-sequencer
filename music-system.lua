local musicPlayer = require "music-player"
local vra8n = require "music.vra8n_serial"

local musicSystem = {}

function musicSystem:new(activeControllers, devices, musicPathTable, priorityTable, baudrate)
  baudrate = baudrate or 38400

  local synthes = {}
  for i, b in ipairs(activeControllers) do
    if b then
      synthes[i] = vra8n:new(devices[i], 0, baudrate)
      print("player", i, "connecting", synthes[i].isConnecting)
    end
  end

  local players = {}
  for i, b in ipairs(activeControllers) do
    if b then
      players[i] = musicPlayer:new(synthes[i], musicPathTable, priorityTable)
    end
  end

  return setmetatable({
    deviceNames = devices,
    baudrate = baudrate,
    synthes = synthes,
    players = players,
  }, { __index = self })
end

function musicSystem:gc()
  for _, v in ipairs(self.synthes) do
    v:allNotesOff()
    v:close()
  end
end

function musicSystem:play(index, key)
  if self.players[index] ~= nil then self.players[index]:play(key) end
end

function musicSystem:stop(index, key)
  if self.players[index] ~= nil then self.players[index]:stop(key) end
end

function musicSystem:nowPlaying(index, key)
  if self.players[index] ~= nil then
    return self.players[index]:nowPlaying(key)
  end
  return false
end

function musicSystem:playAllPlayer(key)
  for _, player in pairs(self.players) do
    player:play(key)
  end
end

function musicSystem:stopAllPlayer(key)
  for _, player in pairs(self.players) do
    if player:nowPlaying(key) then player:stop(key) end
  end
end

function musicSystem:stopAllNotesAllPlayer()
  for _, player in pairs(self.players) do
    player:stopAll()
  end
end

function musicSystem:update(dt)
  for _, player in pairs(self.players) do
    player:update(dt)
  end
end

return musicSystem
