package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local dispatch = assert(loadfile("./programs/station_dispatch.lua"))("__module__")
local schedule = assert(loadfile("./programs/lib/station_schedule.lua"))()

local book = {
  AUGMENTS = {DETECTORS = {}},
  STATIONS = {
    a = {x = 0, y = 64, z = 0, detector_ids = {}, redstone_outputs = {}},
    b = {x = 10, y = 64, z = 0, detector_ids = {}, redstone_outputs = {}},
    c = {x = 20, y = 64, z = 0, detector_ids = {}, redstone_outputs = {}},
  },
  ROUTES = {
    a_to_b = {from = "a", to = "b", via = {}, cruise_kmh = 40, stop_buffer_m = 2, profile = "conservative"},
    b_to_c = {from = "b", to = "c", via = {}, cruise_kmh = 40, stop_buffer_m = 2, profile = "conservative"},
  },
  SCHEDULES = {
    loop = {
      cyclic = true,
      entries = {
        {station = "b", route = "a_to_b", wait = {groups = {{{type = "time_passed", seconds = 0}}}}},
        {station = "c", wait = {groups = {{{type = "time_passed", seconds = 0}}}}},
      },
    },
  },
}

local valid = schedule.validate(book, "loop")
assert(valid.ok == true, table.concat(valid.errors, "\n"))
assert(schedule.resolve_entry_station_id(book, book.SCHEDULES.loop.entries[1]) == "b", "entry.station should be primary")

local route_id = dispatch.resolve_route_for_entry(book, "b", book.SCHEDULES.loop.entries[2])
assert(route_id == "b_to_c", "dispatcher should resolve current station -> entry station")

book.ROUTES.b_to_c_alt = {from = "b", to = "c", via = {}, cruise_kmh = 40, stop_buffer_m = 2, profile = "conservative"}
local ambiguous, ambiguous_error = dispatch.resolve_route_for_entry(book, "b", book.SCHEDULES.loop.entries[2])
assert(ambiguous == nil and tostring(ambiguous_error):find("multiple routes", 1, true), "ambiguous auto-route should fail")

book.SCHEDULES.loop.entries[1].station = "c"
local invalid = schedule.validate(book, "loop")
assert(invalid.ok == false, "entry.station must match explicit route destination")

print("schedule_multi_stop_preview ok")
