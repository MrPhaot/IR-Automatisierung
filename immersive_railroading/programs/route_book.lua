-- Route coordinates are world-specific, so V1 ships only the station-first schema.
return {
  STATIONS = {
    ["1"] = {x = 427, y = 64, z = -148},
    ["2"] = {x = 238, y = 64, z = -77}
  },
  ROUTES = {
    ["1_zu_2"] = {
      waypoints = {
        "1",
        {x = 398, y = 64, z = -210},
        "2"
      },
      cruise_kmh = 55,
      stop_buffer_m = 3
    }
  }
}
