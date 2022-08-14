local music = require "music"
local table2 = require "util.table2"

local musicPlayer = {}

function musicPlayer:new(synth, musicPathTable, priorityTable)
  local musicTable = {}
  for k, path in pairs(musicPathTable) do
    musicTable[k] = music:new(path)
    music.name = k
  end

  return setmetatable({
    musicTable = musicTable,
    synth = synth,
    playingList = {},
    priorityTable = priorityTable,
  }, { __index = self })
end

-- fromContinued: つづきから再生するか
-- デフォルト false
function musicPlayer:play(name, fromContinued)
  fromContinued = fromContinued or false

  if not fromContinued then
    self.musicTable[name]:reset()
  end

  table2.removeItem(self.playingList, name)

  if #self.playingList == 0 then
    table.insert(self.playingList, 1, name)
    return
  end

  if self.priorityTable ~= nil then
    local priority = self.priorityTable[name] or 0
    for i, v in ipairs(self.playingList) do
      local targetPriority = self.priorityTable[v] or 0
      if priority >= targetPriority then
        if i == 1 then
          self.synth:allNotesOff()
        end
        table.insert(self.playingList, i, name)
        return
      end
    end
    table.insert(self.playingList, name)
    return
  end

  self.synth:allNotesOff()
  self.playingList = {}
  table.insert(self.playingList, 1, name)
end

function musicPlayer:stopAll()
  self.synth:allNotesOff()
end

function musicPlayer:stop(name)
  local _, nowName = self:nowMusic()
  if name == nil then
    name = nowName
    if name == nil then return end
  end

  self.musicTable[name]:reset()
  table2.removeItem(self.playingList, name)

  if name ~= nowName then return end

  self.synth:allNotesOff()

  local nextMusic, nextName = self:nowMusic()
  if nextMusic == nil then return end

  local notes = nextMusic:nowNotes()
  for _, v in ipairs(notes) do
    self.synth:noteOn(unpack(v))
  end
end

function musicPlayer:nowMusic()
  if #self.playingList ~= 0 then
    local name = self.playingList[1]
    return self.musicTable[name], name
  end
  return nil
end

function musicPlayer:nowPlaying(name)
  for i, v in ipairs(self.playingList) do
    if v == name then return true end
  end
  return false
end

function musicPlayer:update(dt)
  local events
  for i, v in ipairs(self.playingList) do
    self.musicTable[v]:update(dt)
    local e = self.musicTable[v]:readEvents()
    if i == 1 then events = e end
  end

  if events == nil then return end

  for _, event in ipairs(events) do
    if event[1] == "noteOn" then
      self.synth:noteOn(event[2], event[3])
    elseif event[1] == "noteOff" then
      self.synth:noteOff(event[2])
    elseif event[1] == "controlChange" then
      self.synth:controlChange(event[2], event[3])
    end
  end


  local nowMusic, nowName = self:nowMusic()
  if nowMusic:isEnd() then
    self:stop(nowName)
    return
  end
end

return musicPlayer
