local Timer = require "util.timer"
local controlTypes = require "music.control_type"
local controlTypeNames = require "music.control_type_names"
local table2 = require "util.table2"

local SoundChanger = {}
function SoundChanger:new(musicSystem)
  local changing = {}
  for i = 1, 31 do
    changing[i] = 64
  end
  return setmetatable({ musicSystem = musicSystem, changing = changing, timer = Timer:new(0.1) }, { __index = self })
end

function SoundChanger:setSoundControl(controlType, value)
  if controlType < 32 and controlType > 0 then
    self.changing[controlType] = value
  end
end

function SoundChanger:update(dt)
  local copiedSCs = table2.merge({}, self.changing)
  if self.timer:executable(dt) then
    for scIndex, scValue in ipairs(copiedSCs) do
      local scType = controlTypes[controlTypeNames[scIndex]]
      for _, player in ipairs(self.musicSystem.players) do
        local nowValue = player.synth.controlls[scType]
        if nowValue == nil then
          nowValue = scValue
        end
        if nowValue < scValue then
          nowValue = nowValue + 1
          player.synth:controlChange(scType, nowValue)
        elseif nowValue > scValue then
          nowValue = nowValue - 1
          player.synth:controlChange(scType, nowValue)
        end
      end
    end
  end
end

return SoundChanger
