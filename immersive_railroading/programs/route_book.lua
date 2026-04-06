-- Coordinates, detector ids, and schedules are save-specific, so the shipped
-- route book stays empty while preserving the frozen V1 schema.
return {
  AUGMENTS = {
    DETECTORS = {},
  },
  STATIONS = {},
  ROUTES = {},
  SCHEDULES = {},
}
