local INPUT_UP    = 'up'
local INPUT_LEFT  = 'left'
local INPUT_DOWN  = 'down'
local INPUT_RIGHT = 'right'
local INPUT_A     = 'a'
local INPUT_B     = 'b'

local storage = require "util.storage":load("joystick_setting", true)
if #storage.data == 0 then
  return {
    -- user1
    {
      type    = 'joystick',
      mapping = {
        [INPUT_UP]    = { index = 1, type = 'button' },
        [INPUT_LEFT]  = { index = 2, type = 'button' },
        [INPUT_DOWN]  = { index = 4, type = 'button' },
        [INPUT_RIGHT] = { index = 3, type = 'button' },
        [INPUT_A]     = { index = 5, type = 'button' },
        [INPUT_B]     = { index = 6, type = 'button' },
      },
      options = {
        guid = '',
        name = 'Unknown MONOLITH CONTROLLER#1',
      },
    },
    -- user2
    {
      type    = 'joystick',
      mapping = {
        [INPUT_UP]    = { index = 1, type = 'button' },
        [INPUT_LEFT]  = { index = 2, type = 'button' },
        [INPUT_DOWN]  = { index = 4, type = 'button' },
        [INPUT_RIGHT] = { index = 3, type = 'button' },
        [INPUT_A]     = { index = 5, type = 'button' },
        [INPUT_B]     = { index = 6, type = 'button' },
      },
      options = {
        guid = '',
        name = 'Unknown MONOLITH CONTROLLER#2',
      },
    },
    -- user3
    {
      type    = 'joystick',
      mapping = {
        [INPUT_UP]    = { index = 1, type = 'button' },
        [INPUT_LEFT]  = { index = 2, type = 'button' },
        [INPUT_DOWN]  = { index = 4, type = 'button' },
        [INPUT_RIGHT] = { index = 3, type = 'button' },
        [INPUT_A]     = { index = 5, type = 'button' },
        [INPUT_B]     = { index = 6, type = 'button' },
      },
      options = {
        guid = '',
        name = 'Unknown MONOLITH CONTROLLER#3',
      },
    },
    -- user4
    {
      type    = 'joystick',
      mapping = {
        [INPUT_UP]    = { index = 1, type = 'button' },
        [INPUT_LEFT]  = { index = 2, type = 'button' },
        [INPUT_DOWN]  = { index = 4, type = 'button' },
        [INPUT_RIGHT] = { index = 3, type = 'button' },
        [INPUT_A]     = { index = 5, type = 'button' },
        [INPUT_B]     = { index = 6, type = 'button' },
      },
      options = {
        guid = '',
        name = 'Unknown MONOLITH CONTROLLER#4',
      },
    },
  }
end
return storage.data
