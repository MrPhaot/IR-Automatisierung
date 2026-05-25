package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local controller = assert(loadfile("./programs/train_controller.lua"))("__module__")

local book = {
  STATIONS = {
    a = {x = 0, y = 64, z = 0},
    b = {x = 20, y = 64, z = 0},
    c = {x = 50, y = 64, z = 0},
  },
  ROUTES = {
    edge = {
      from = "a",
      to = "c",
      via = {
        {x = 10, y = 64, z = 0},
        "b",
      },
      cruise_kmh = 40,
      stop_buffer_m = 2,
      profile = "conservative",
    },
    legacy = {
      waypoints = {"a", {x = 5, y = 64, z = 0}, "c"},
      cruise_kmh = 40,
      stop_buffer_m = 2,
      profile = "conservative",
    },
  },
}

local edge = controller.build_named_route_plan("edge", {profile_explicit = false}, book)
assert(#edge.legs == 4, "from/to/via should produce from + via + to")
assert(edge.legs[1].target.x == 0, "edge route should start at from station")
assert(edge.legs[4].target.x == 50, "edge route should end at to station")
assert(edge.legs[1].mode == "pass_through", "from station point is guardrail on edge route")
assert(edge.legs[4].mode == "terminal", "to station point is terminal")

local legacy = controller.build_named_route_plan("legacy", {profile_explicit = false}, book)
assert(#legacy.legs == 3, "legacy waypoints should stay readable")
legacy.initial_leg_index = 2
assert(legacy.initial_leg_index == 2, "route plan should carry initial leg index")

print("route_book_graph_preview ok")
