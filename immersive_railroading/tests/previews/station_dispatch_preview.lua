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
        loader = {address = "redstone-a", side = "north", strength = 15, active_high = true},
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

do
  local missing_redstone = {
    STATIONS = {
      a = {
        redstone_outputs = {
          loader = {address = "redstone-missing", side = "north"},
        },
      },
    },
  }
  local resolver = dispatch._make_redstone_proxy_resolver(missing_redstone)
  local redstone_proxy, redstone_error = resolver(missing_redstone.STATIONS.a.redstone_outputs.loader)
  assert(
    redstone_proxy == nil and (
      tostring(redstone_error):find("redstone component address redstone%-missing is unavailable") ~= nil
      or tostring(redstone_error):find("component API unavailable", 1, true) ~= nil
    ),
    "missing redstone addresses should return a friendly dispatcher error"
  )
  assert(dispatch._component_available("redstone") == false, "component availability helper should be defensive without a component api")
end

print("station_dispatch_preview ok")
