package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local schedule = assert(loadfile("./programs/lib/station_schedule.lua"))()

local book = {
  STATIONS = {
    ["2"] = {
      detector_ids = {"mine_front", "mine_rear"},
      redstone_outputs = {
        loader = {side = "north", strength = 15, active_high = true},
        departure = {side = "south", strength = 15, active_high = true, pulse_ticks = 5},
      },
    },
  },
  ROUTES = {
    ["1_zu_2"] = {
      waypoints = {"1", "2"},
    },
  },
  SCHEDULES = {
    ore_loop = {
      entries = {
        {
          route = "1_zu_2",
          wait = {
            groups = {
              {
                {
                  type = "cargo_percent",
                  scope = "station_any_detector",
                  comparator = "<=",
                  value = 5,
                  redstone = {output = "loader", mode = "while_pending"},
                },
                {
                  type = "inactivity",
                  seconds = 3,
                },
              },
              {
                {
                  type = "time_passed",
                  seconds = 30,
                  redstone = {output = "departure", mode = "on_departure_pulse"},
                },
              },
            },
          },
        },
      },
    },
  },
}

local valid = schedule.validate(book, "ore_loop")
assert(valid.ok == true, "frozen DNF wait schema should validate")

local samples = {
  [0] = {mine_front = {info = {cargo_percent = 50}}, mine_rear = {info = {cargo_percent = 70}}},
  [4] = {mine_front = {info = {cargo_percent = 4}}, mine_rear = {info = {cargo_percent = 7}}},
}

local session = schedule.create_wait_session(book, "2", book.SCHEDULES.ore_loop.entries[1].wait, function()
  local clock = _G.__preview_clock or 0
  return samples[clock] or samples[4]
end)

_G.__preview_clock = 0
local tick0 = schedule.tick_wait_session(session, 0)
assert(tick0.complete == false, "initial wait should still be pending")
assert(tick0.pending_outputs.loader == true, "while_pending output should stay active while condition is false")

_G.__preview_clock = 4
local tick1 = schedule.tick_wait_session(session, 4)
assert(tick1.complete == false, "inactivity should reset when detector metrics materially change")

_G.__preview_clock = 4
local tick2 = schedule.tick_wait_session(session, 8)
assert(tick2.complete == true, "group A should complete once cargo and inactivity are satisfied")
assert(tick2.departure_pulses.departure == true, "departure pulse should fire once wait completes")

local split_entry = {
  route = "1_zu_2",
  wait = {
    groups = {
      {
        {
          type = "time_passed",
          seconds = 10,
        },
      },
    },
  },
  redstone = {
    rules = {
      {
        output = "loader",
        groups = {
          {
            {
              type = "cargo_percent",
              scope = "station_any_detector",
              comparator = "<=",
              value = 5,
            },
          },
        },
      },
    },
  },
}

local split_valid = schedule.validate({
  STATIONS = book.STATIONS,
  ROUTES = book.ROUTES,
  SCHEDULES = {split = {entries = {split_entry}}},
}, "split")
assert(split_valid.ok == true, "independent redstone rule schema should validate")

local split_session = schedule.create_wait_session(book, "2", split_entry, function()
  local clock = _G.__preview_clock or 0
  return samples[clock] or samples[4]
end)

_G.__preview_clock = 4
local split_tick0 = schedule.tick_wait_session(split_session, 4)
assert(split_tick0.complete == false, "wait chain should still control departure independently of redstone rules")
assert(split_tick0.pending_outputs.loader == true, "redstone rule should be active while waiting and condition is true")

_G.__preview_clock = 4
local split_tick1 = schedule.tick_wait_session(split_session, 14)
assert(split_tick1.complete == true, "wait chain should complete on its own schedule")
assert(split_tick1.pending_outputs.loader == nil, "schedule redstone outputs should shut down once wait completes")

print("station_schedule_preview ok")
