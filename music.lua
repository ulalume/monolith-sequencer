local json = require "rxi-json-lua"
local table2 = require "util.table2"

local music = {}

function music:new(jsonPath)
  local jsonStr = love.filesystem.read("string", jsonPath)

  local t = json.decode(jsonStr)

  local isLoop = false
  if t.is_loop then
    isLoop = true
  end
  return setmetatable(
    {
      events = t.events,
      releaseTime = t.release_time or 0.1,
      isLoop = isLoop,
      -- now
      noteIds = {},
      picthes = {},
      velocities = {},
      tempTime = 0,
      time = 0
    },
    { __index = self }
  )
end

function music:update(dt)
  self.tempTime = self.time
  self.time = self.time + dt
end

--[[{
  "type": "control",

  "name": 80,
  "value": 55,

  "time": 0,
  "once": false
}]]
function music:controlChangeRealtime(name, value)
  table.insert(
    self.events,
    {
      type = "control",
      time = self.time,
      name = name,
      value = value,
      once = true
    }
  )
end

function music:readEvents()
  local events = {}

  if self:isEnd() then
    return events
  end

  for id, event in ipairs(self.events) do
    if event.type == "note" then
      if self.tempTime <= event.time and event.time < self.time then
        --[[
        local pitch = self:nowNote()
        if pitch ~= nil then
          table.insert(events, {"noteOff", pitch})
        end
        ]]
        table.insert(events, { "noteOn", event.pitch, event.velocity })
        table.insert(self.noteIds, 1, id)

        self.picthes[id] = event.pitch
        self.velocities[id] = event.velocity
      end

      if self.tempTime <= event.time + event.duration and event.time + event.duration < self.time then
        table.insert(events, { "noteOff", event.pitch })
        table2.removeItem(self.noteIds, id)

        self.picthes[id] = nil
        self.velocities[id] = nil

        --[[
        local pitch, velocity = self:nowNote()
        if pitch ~= nil then
          table.insert(events, {"noteOn", pitch, velocity})
        end
        ]]
      end
    end
  end

  if self.isLoop then
    local endtime = self:getEndTime()
    if self.time > endtime then
      self.tempTime = self.tempTime - endtime
      self.time = self.time - endtime
      table2.merge(events, self:readEvents())
    end
  end

  return events
end

function music:reset()
  self.time = 0
  self.tempTime = 0

  self.noteIds = {}
  self.picthes = {}
  self.velocities = {}
end

function music:getEndTime()
  if self.endTime == nil then
    self.endTime = 0
    for id, event in ipairs(self.events) do
      if event.type == "note" then
        self.endTime = math.max(self.endTime, event.time + event.duration)
      elseif event.type == "control" then
        self.endTime = math.max(self.endTime, event.time)
      end
    end
  end
  return self.endTime
end

function music:isEnd()
  if self.isLoop then
    return false
  end
  return self.tempTime > self:getEndTime() + self.releaseTime
end

function music:nowNote()
  if #self.noteIds ~= 0 then
    local id = self.noteIds[1]
    return self.picthes[id], self.velocities[id]
  end
end

function music:nowNotes()
  local notes = {}
  for i, v in ipairs(self.noteIds) do
    local id = self.noteIds[1]
    table.insert(notes, 1, { self.picthes[id], self.velocities[id] })
  end
  return notes
end

return music
