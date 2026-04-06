package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local dispatch = assert(loadfile("./programs/station_dispatch.lua"))("__module__")

local book = {
  AUGMENTS = {
    DETECTORS = {
      mine_front = {address = "addr-a", label = "Mine Front", sort_order = 10},
    },
  },
  STATIONS = {
    ["1"] = {
      x = 0, y = 64, z = 0,
      detector_ids = {"mine_front"},
      redstone_outputs = {
        loader = {side = "north", strength = 15, active_high = true},
      },
    },
    ["2"] = {
      x = 10, y = 64, z = 0,
      detector_ids = {},
      redstone_outputs = {},
    },
  },
  ROUTES = {
    ["1_zu_2"] = {
      waypoints = {"1", "2"},
      cruise_kmh = 40,
      stop_buffer_m = 2,
      profile = "conservative",
    },
  },
  SCHEDULES = {
    ore_loop = {
      cyclic = false,
      entries = {
        {
          route = "1_zu_2",
          wait = {
            groups = {
              {
                {
                  type = "time_passed",
                  seconds = 0,
                },
              },
            },
          },
        },
      },
    },
  },
}

local valid = dispatch.validate_route_book(book)
assert(valid.ok == true, "minimal valid schedule book should validate")

book.SCHEDULES.ore_loop.entries[1].wait.groups[1][1].redstone = {output = "missing", mode = "while_pending"}
local invalid = dispatch.validate_route_book(book)
assert(invalid.ok == false, "unknown station output should fail dispatcher validation")

print("station_dispatch_preview ok")
