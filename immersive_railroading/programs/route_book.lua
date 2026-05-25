-- Coordinates, detector ids, and schedules are save-specific, so the shipped
-- route book stays empty while preserving the frozen V1 schema.
return {
  AUGMENTS = {
    DETECTORS = {},
  },
  STATIONS = {
    -- [station_id] = {
    --   display_name = "...",
    --   x = 0, y = 0, z = 0,
    --   detector_ids = {},
    --   redstone_outputs = {},
    -- },
  },
  ROUTES = {
    -- [route_id] = {
    --   from = station_id,
    --   to = station_id,
    --   via = {{x = 0, y = 0, z = 0}},
    --   cruise_kmh = 65,
    --   profile = "conservative",
    --   stop_buffer_m = 6,
    -- },
  },
  SCHEDULES = {
    -- [schedule_id] = {
    --   cyclic = true,
    --   entries = {
    --     {
    --       station = station_id,
    --       route = route_id, -- optional after dispatcher knows current station
    --       wait = {groups = {{{type = "time_passed", seconds = 0}}}},
    --       redstone = {rules = {}},
    --     },
    --   },
    -- },
  },
}
