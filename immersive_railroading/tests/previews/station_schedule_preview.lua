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

do
  local book2 = {
    STATIONS = {
      x = {detector_ids = {"a", "b", "c"}, redstone_outputs = {out = {}}},
    },
    ROUTES = {},
    SCHEDULES = {
      probe = {
        entries = {
          {
            station = "x",
            wait = {
              groups = {
                {
                  {
                    type = "cargo_percent",
                    scope = {station_id = "x", detector_ids = {"a", "b"}},
                    comparator = "<=",
                    value = 5,
                  },
                },
              },
            },
          },
        },
      },
    },
  }
  local valid_probe = schedule.validate(book2, "probe")
  assert(valid_probe.ok == true, "per-station detector-set scope with explicit station should validate")

  local probe_entry = book2.SCHEDULES.probe.entries[1]
  local session = schedule.create_wait_session(book2, "x", probe_entry.wait, function()
    return _G.__probe_samples or {}
  end)
  _G.__probe_samples = {a = {info = {cargo_percent = 90}}, b = {info = {cargo_percent = 90}}, c = {info = {cargo_percent = 4}}}
  local tick_incomplete = schedule.tick_wait_session(session, 0)
  assert(tick_incomplete.complete == false, "detector-set scope should resolve to only the named detectors (OR)")
  _G.__probe_samples = {a = {info = {cargo_percent = 4}}, b = {info = {cargo_percent = 90}}, c = {info = {cargo_percent = 90}}}
  local tick_complete = schedule.tick_wait_session(session, 5)
  assert(tick_complete.complete == true, "detector-set scope should complete when a named detector matches")
end

do
  local book3 = {
    STATIONS = {x = {detector_ids = {"a"}, redstone_outputs = {out = {}}}},
    ROUTES = {},
    SCHEDULES = {
      legacy = {
        entries = {
          {
            station = "x",
            wait = {
              groups = {
                {
                  {
                    type = "cargo_percent",
                    scope = {all_detectors = true},
                    comparator = ">=",
                    value = 1,
                  },
                },
              },
            },
          },
        },
      },
    },
  }
  local v = schedule.validate(book3, "legacy")
  assert(v.ok == true, "legacy-normalized scope with nil station_id should still validate")
end

do
  local book4 = {
    STATIONS = {
      a = {detector_ids = {}, redstone_outputs = {out_a = {}}},
      b = {detector_ids = {}, redstone_outputs = {out_b = {}}},
    },
    ROUTES = {},
    SCHEDULES = {
      multi = {
        entries = {
          {
            station = "a",
            wait = {groups = {{{type = "time_passed", seconds = 0}}}},
            redstone = {rules = {{output = "out_b", groups = {{{type = "time_passed", seconds = 0}}}}}},
          },
          {station = "b", wait = {groups = {{{type = "time_passed", seconds = 0}}}}},
        },
      },
    },
  }
  local v = schedule.validate(book4, "multi")
  assert(v.ok == true, "redstone rule may reference any entry-station output via the union")
end

do
  local book5 = {
    STATIONS = {
      a = {detector_ids = {}, redstone_outputs = {out_a = {}}},
      b = {detector_ids = {}, redstone_outputs = {out_b = {}}},
    },
    ROUTES = {
      to_a = {waypoints = {"x", "a"}},
      to_b = {waypoints = {"x", "b"}},
    },
    SCHEDULES = {
      arrival = {
        entries = {
          {route = "to_a", station = "a", wait = {groups = {{{type = "time_passed", seconds = 0}}}}},
          {route = "to_b", station = "b", wait = {groups = {{{type = "time_passed", seconds = 0}}}}},
        },
      },
    },
  }
  local valid_arrival = schedule.validate(book5, "arrival")
  assert(valid_arrival.ok == true, "arrived_at_station with entry station should validate")

  local invalid_arrival_book = {
    STATIONS = {
      a = {detector_ids = {}, redstone_outputs = {}},
      z = {detector_ids = {}, redstone_outputs = {}},
    },
    ROUTES = {
      to_a = {waypoints = {"x", "a"}},
      to_z = {waypoints = {"x", "z"}},
    },
    SCHEDULES = {
      bad = {
        entries = {
          {route = "to_a", station = "a", wait = {groups = {{{type = "arrived_at_station", station = "z"}}}}},
        },
      },
    },
  }
  local invalid_arrival = schedule.validate(invalid_arrival_book, "bad")
  assert(invalid_arrival.ok == false, "arrived_at_station with non-entry station should fail validation")
end

do
  local book6 = {
    STATIONS = {
      a = {detector_ids = {}, redstone_outputs = {out = {pulse_ticks = 10}}},
    },
    ROUTES = {
      dummy = {waypoints = {"x", "a"}},
    },
    SCHEDULES = {
      pulse_rule = {
        entries = {
          {
            route = "dummy",
            station = "a",
            wait = {groups = {{{type = "time_passed", seconds = 1}}}},
            redstone = {
              rules = {
                {output = "out", signal = "pulse", pulse_ticks = 15, groups = {{{type = "arrived_at_station", station = "a"}}}},
              },
            },
          },
        },
      },
    },
  }
  local v = schedule.validate(book6, "pulse_rule")
  assert(v.ok == true, "redstone rule with signal=pulse and pulse_ticks should validate")

  local session = schedule.create_wait_session(book6, "a", book6.SCHEDULES.pulse_rule.entries[1], function() return {} end)
  local tick0 = schedule.tick_wait_session(session, 0)
  assert(tick0.arrival_pulses ~= nil, "arrival_pulses should be present")
  assert(#tick0.arrival_pulses == 1, "pulse should fire on first evaluation")
  assert(tick0.arrival_pulses[1].name == "out", "pulse should target the correct output")
  assert(tick0.arrival_pulses[1].config.pulse_ticks == 15, "per-rule pulse_ticks should override output default")

  local tick1 = schedule.tick_wait_session(session, 1)
  assert(#(tick1.arrival_pulses or {}) == 0, "pulse should not re-fire on second evaluation (rising edge)")
end

do
  local book7 = {
    STATIONS = {
      a = {detector_ids = {}, redstone_outputs = {out = {}}},
      b = {detector_ids = {}, redstone_outputs = {out = {}}},
    },
    ROUTES = {
      dummy_a = {waypoints = {"x", "a"}},
      dummy_b = {waypoints = {"x", "b"}},
    },
    SCHEDULES = {
      multi_arrival = {
        entries = {
          {
            route = "dummy_a",
            station = "a",
            wait = {groups = {{{type = "time_passed", seconds = 1}}}},
            redstone = {
              rules = {
                {output = "out", signal = "pulse", groups = {{{type = "arrived_at_station", station = "a"}}}},
              },
            },
          },
          {
            route = "dummy_b",
            station = "b",
            wait = {groups = {{{type = "time_passed", seconds = 1}}}},
          },
        },
      },
    },
  }
  local v = schedule.validate(book7, "multi_arrival")
  assert(v.ok == true, "arrived_at_station with multiple entries should validate")

  local session_a = schedule.create_wait_session(book7, "a", book7.SCHEDULES.multi_arrival.entries[1], function() return {} end)
  local tick_a = schedule.tick_wait_session(session_a, 0)
  assert(#(tick_a.arrival_pulses or {}) == 1, "pulse should fire when arrived at matching entry station")
end

print("station_schedule_preview ok")
