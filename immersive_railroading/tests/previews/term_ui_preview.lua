package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local ui = assert(loadfile("./programs/lib/term_ui.lua"))()
local required_ui = require("lib.term_ui")
local editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")

local function find_target(screen, predicate)
  for _, group in ipairs({screen.modal_targets or {}, screen.targets or {}}) do
    for _, target in ipairs(group) do
      if predicate(target) then
        return target
      end
    end
  end
  return nil
end

local state = editor.new_state()
local screen = editor.build_screen(state, 100, 30)
local medium_screen = editor.build_screen(state, 70, 20)
local tier2_screen = editor.build_screen(state, 80, 25)
local compact_screen = editor.build_screen(state, 54, 18)
local minimum_screen = editor.build_screen(state, 50, 16)
local large_screen = editor.build_screen(state, 160, 50)
local comfort_lines = ui.render_lines(100, 30, screen.buffer)
local medium_lines = ui.render_lines(70, 20, medium_screen.buffer)
local tier2_lines = ui.render_lines(80, 25, tier2_screen.buffer)
local compact_lines = ui.render_lines(54, 18, compact_screen.buffer)

assert(type(screen.buffer) == "table" and #screen.buffer > 0, "editor should render a screen buffer")
assert(type(screen.targets) == "table" and #screen.targets > 0, "editor should expose clickable targets")
assert(ui.API_VERSION == 2, "term_ui should expose api version 2")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, 2) == true, "hit testing should work")
assert(ui.hit(nil, 3, 2) == false, "hit should ignore nil rects")
assert(ui.hit({x = 1, y = 1, width = nil, height = 2}, 3, 2) == false, "hit should ignore nil width")
assert(ui.hit({x = 1, y = 1, width = 5, height = nil}, 3, 2) == false, "hit should ignore nil height")
assert(ui.hit({x = 1, y = 1, width = 0, height = 2}, 3, 2) == false, "hit should reject zero width")
assert(ui.hit({x = 1, y = 1, width = 5, height = 0}, 3, 2) == false, "hit should reject zero height")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, nil, 2) == false, "hit should reject nil px")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, nil) == false, "hit should reject nil py")
assert(ui.fit_text("abcdef", 4) == "abc>", "fit_text should mark truncation")
assert(editor.parse_cli_mode({}) == "run", "empty argv should keep normal run mode")
assert(editor.parse_cli_mode({"diagnose-ui"}) == "diagnose-ui", "plain diagnose-ui should enable diagnostics")
assert(editor.parse_cli_mode({"--diagnose-ui"}) == "diagnose-ui", "direct flag should enable diagnostics when delivered to the chunk")
assert(editor.parse_cli_mode({"--", "--diagnose-ui"}) == "diagnose-ui", "double-dash form should enable diagnostics")
assert(compact_screen.layout.tier == "compact", "54x18 should use compact layout")
assert(minimum_screen.layout.tier == "minimum", "50x16 should use minimum-size fallback")
assert(screen.layout.tier == "comfort", "100x30 should use comfort layout")
assert(large_screen.layout.tier == "comfort", "160x50 should use comfort layout")
assert(medium_screen.layout.tier == "compact", "70x20 should use compact layout")
assert(tier2_screen.layout.tier == "compact", "80x25 should use compact layout")

assert(comfort_lines[1]:find("IR Schedule Editor", 1, true) ~= nil, "comfort frame should contain title")
assert(comfort_lines[2]:find("Detectors", 1, true) ~= nil, "comfort frame should show tabs")
assert(table.concat(comfort_lines, "\n"):find("Known Detectors", 1, true) ~= nil, "comfort frame should show detector panel")
assert(table.concat(comfort_lines, "\n"):find("%[ Add %]", 1) ~= nil, "comfort frame should show action buttons")

assert(table.concat(medium_lines, "\n"):find("Schedules", 1, true) ~= nil or table.concat(medium_lines, "\n"):find("Detectors", 1, true) ~= nil, "70x20 should show compact panels")
assert(table.concat(tier2_lines, "\n"):find("Det", 1, true) ~= nil, "80x25 should keep compact tabs")
assert(table.concat(compact_lines, "\n"):find("Det", 1, true) ~= nil, "54x18 should show compact tabs")
assert(table.concat(compact_lines, "\n"):find("%[ Add %]", 1) ~= nil, "54x18 should show compact buttons")
local compact_has_status = false
for _, line in ipairs(compact_lines) do
  if line:find("UI tier=", 1, true) ~= nil or line:find("Ready", 1, true) ~= nil then
    compact_has_status = true
    break
  end
end
assert(compact_has_status == true, "status line should remain visible")
assert(table.concat(comfort_lines, "\n"):find("renderer=", 1, true) == nil, "normal editor status should not contain diagnostics")

do
  local modal = {
    fields = {
      editor.make_text_field({key = "name", label = "Name", value = "Station 1"}),
      editor.make_repeatable_text_field({
        key = "waypoints",
        label = "Waypoints",
        values = {"427,64,-148", "398,64,-210"},
        min_items = 1,
      }),
    },
    active_row = 1,
    scroll_y = 0,
  }
  local rows = editor.build_modal_rows(modal)
  assert(#rows == 4, "repeatable modal fields should expand into item and add rows")
  assert(rows[1].kind == "text", "normal modal fields should stay text rows")
  assert(rows[2].kind == "repeat_item" and rows[2].item_index == 1, "first repeatable value should become an item row")
  assert(rows[4].kind == "repeat_add", "repeatable fields should end with an add row")

  modal.active_row = 4
  editor.ensure_modal_row_visible(modal, 2)
  assert(modal.scroll_y == 2, "active modal rows should scroll into view")

  local values = editor.collect_modal_values(modal)
  assert(values.name == "Station 1", "collect_modal_values should keep text values")
  assert(type(values.waypoints) == "table" and #values.waypoints == 2, "collect_modal_values should keep repeatable values as arrays")
end

do
  local modal = {
    fields = {
      editor.make_repeatable_group_field({
        key = "redstone_outputs",
        label = "Redstone I/Os",
        min_items = 0,
        item_fields = {
          {key = "id", label = "ID", default = ""},
          {key = "address", label = "Address", default = ""},
          {key = "side", label = "Side", default = "north"},
          {key = "strength", label = "Strength", default = "15"},
          {key = "pulse_ticks", label = "Pulse", default = "20"},
          {key = "active_high", label = "Active High", default = "true"},
        },
        items = {
          {id = "loader", address = "redstone-a", side = "north", strength = "15", pulse_ticks = "20", active_high = "true"},
        },
      }),
    },
    active_row = 1,
    scroll_y = 0,
  }
  local rows = editor.build_modal_rows(modal)
  assert(rows[1].kind == "group_item_field", "group rows should expose subfields as modal rows")
  assert(rows[5].kind == "group_item_field", "all group subfields should become modal rows")
  assert(rows[6].kind == "group_item_field", "all configured group item fields should stay visible")
  assert(rows[7].kind == "group_add", "group fields should expose an add row")
  local values = editor.collect_modal_values(modal)
  assert(type(values.redstone_outputs) == "table" and values.redstone_outputs[1].id == "loader", "group modal values should serialize as object arrays")
end

do
  local state = editor.new_state()
  state.modal = {
    title = "Edit Station",
    fields = {
      editor.make_repeatable_group_field({
        key = "redstone_outputs",
        label = "Redstone I/Os",
        min_items = 0,
        item_fields = {
          {key = "id", label = "ID", default = ""},
          {key = "address", label = "Address", default = ""},
          {key = "side", label = "Side", default = "north"},
          {key = "strength", label = "Strength", default = "15"},
          {key = "pulse_ticks", label = "Pulse", default = "20"},
          {key = "active_high", label = "Active High", default = "true"},
        },
        items = {},
      }),
    },
    active_row = 1,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  local modal_screen = editor.build_screen(state, 100, 30)
  local modal_text = table.concat(ui.render_lines(100, 30, modal_screen.buffer), "\n")
  assert(modal_text:find("Redstone I/Os %[%+%]") ~= nil, "empty redstone io add row should show its label")
end

do
  local state = editor.new_state()
  state.modal = {
    title = "Edit Station",
    fields = {
      editor.make_repeatable_group_field({
        key = "redstone_outputs",
        label = "Redstone I/Os",
        min_items = 0,
        item_fields = {
          {key = "id", label = "ID", default = ""},
          {key = "address", label = "Address", default = ""},
          {key = "side", label = "Side", default = "north"},
          {key = "strength", label = "Strength", default = "15"},
          {key = "pulse_ticks", label = "Pulse", default = "20"},
          {key = "active_high", label = "Active High", default = "true"},
        },
        items = {
          {id = "", address = "", side = "north", strength = "15", pulse_ticks = "20", active_high = "true"},
        },
      }),
    },
    active_row = 1,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  local before_rows = editor.build_modal_rows(state.modal)
  assert(#before_rows == 7, "single redstone io block should render six subfields plus add row")
  editor.handle_key_down(state, 0, 14)
  local after_rows = editor.build_modal_rows(state.modal)
  assert(#after_rows == 7, "backspace on empty group subfield should not delete the redstone io block")
  editor.handle_key_down(state, 0, 211)
  local after_delete_rows = editor.build_modal_rows(state.modal)
  assert(#after_delete_rows == 7, "delete on empty group subfield should not delete the redstone io block")
end

do
  local state = editor.new_state()
  state.modal = {
    title = "Edit Station",
    fields = {
      editor.make_repeatable_group_field({
        key = "redstone_outputs",
        label = "Redstone I/Os",
        min_items = 0,
        item_fields = {
          {key = "id", label = "ID", default = ""},
          {key = "address", label = "Address", default = ""},
          {key = "side", label = "Side", default = "north", options = {"north", "south"}},
          {key = "strength", label = "Strength", default = "15"},
          {key = "pulse_ticks", label = "Pulse", default = "20"},
          {key = "active_high", label = "Active High", default = "true", options = {"false", "true"}},
        },
        items = {
          {id = "loader", address = "redstone-a", side = "north", strength = "15", pulse_ticks = "20", active_high = "true"},
        },
      }),
    },
    active_row = 3,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  editor.handle_key_down(state, 0, 28)
  local chooser_rows = editor.build_modal_rows(state.modal)
  local chooser_row = chooser_rows[#chooser_rows]
  assert(chooser_row.kind == "choice_chooser", "group choice subfields should open a chooser instead of cycling inline")
  editor.handle_key_down(state, 0, 205)
  local moved_rows = editor.build_modal_rows(state.modal)
  local moved_row = moved_rows[#moved_rows]
  assert(moved_row.chooser.selected == 2, "choice chooser should move selection with keyboard input")
end

do
  local chain_field = editor.make_condition_chain_field(nil)
  local modal = {
    fields = {chain_field},
    active_row = 1,
    scroll_y = 0,
  }
  local rows = editor.build_modal_rows(modal)
  assert(rows[1].kind == "chain_tokens", "condition-chain rows should begin with chain tokens")
  assert(rows[1].line.tokens[1].kind == "plus", "empty chains should begin with a start plus token")
  local values = editor.collect_modal_values({
    fields = {chain_field},
  })
  assert(type(values.wait_chain.groups) == "table" and values.wait_chain.groups[1][1].type == "time_passed", "empty condition chains should fall back to a default wait group")
end

do
  local condition = editor.make_chain_condition({
    type = "cargo_percent",
    comparator = ">=",
    value = 90,
    scope = {detector_id = "mine_front"},
  })
  local runtime = editor.runtime_condition_from_editor(condition)
  assert(runtime.type == "cargo_percent", "runtime condition conversion should keep the type")
  assert(runtime.comparator == ">=" and runtime.value == 90, "runtime condition conversion should keep comparator conditions")
  assert(type(runtime.scope) == "table" and runtime.scope.detector_id == "mine_front", "runtime condition conversion should parse detector scopes")
  assert(runtime.redstone == nil, "wait runtime conversion should no longer embed redstone into wait conditions")
  local rules = editor.runtime_redstone_rules_from_editor({
    rules = {
      {
        output = {value = "loader"},
        groups = {
          {
            conditions = {condition},
          },
        },
      },
    },
  })
  assert(#rules == 1 and rules[1].output == "loader", "redstone editor should serialize dedicated rules")
end

do
  local groups = editor.runtime_groups_from_chain({
    groups = {
      {
        conditions = {
          editor.make_chain_condition({type = "time_passed", seconds = 5}),
          editor.make_chain_condition({type = "inactivity", seconds = 10}),
        },
      },
      {
        conditions = {
          editor.make_chain_condition({type = "cargo_percent", comparator = ">=", value = 90, scope = "station_any_detector"}),
        },
      },
    },
  })
  assert(#groups == 2 and #groups[1] == 2 and #groups[2] == 1, "runtime_groups_from_chain should preserve AND/OR structure")
end

do
  local book = editor.new_state().book
  book.STATIONS.mine = {
    display_name = "Mine",
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a"},
      depart = {address = "redstone-b"},
    },
  }
  book.ROUTES.ore = {waypoints = {"mid", "mine"}}
  assert(editor.route_destination_station_id(book, "ore") == "mine", "route destination helper should resolve the last station waypoint")
  local ids = editor.available_redstone_ids_for_route_destination(book, "ore")
  assert(#ids == 2 and ids[1] == "depart" and ids[2] == "loader", "available redstone ids should come from the route destination station")
end

do
  local state = editor.new_state()
  state.book.STATIONS.mine = {
    display_name = "Mine",
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a"},
    },
  }
  state.book.ROUTES.ore = {waypoints = {"mid", "mine"}}
  state.modal = {
    title = "Edit Schedule",
    fields = {
      editor.make_text_field({key = "route", label = "Route", value = "ore"}),
      editor.make_condition_chain_field({
        cyclic = false,
        entries = {
          {
            route = "ore",
            wait = {groups = {}},
          },
        },
      }),
    },
    active_row = 1,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  local modal_screen = editor.build_screen(state, 100, 30)
  assert(type(modal_screen.modal_targets) == "table" and #modal_screen.modal_targets > 0, "open modals should render dedicated modal targets")
  local start_target = find_target(modal_screen, function(target)
    return target.id == "modal:chain:plus" and target.modal_chain_position and target.modal_chain_position.location == "start"
  end)
  assert(start_target ~= nil, "empty condition chains should expose a clickable start plus")
  assert(editor.handle_click(state, start_target.x, start_target.y, modal_screen) == true, "clicking the start plus should be handled")
  local chain_field = state.modal.fields[2]
  assert(chain_field.chooser and chain_field.chooser.kind == "operator", "first chain plus should open the join chooser")

  local operator_screen = editor.build_screen(state, 100, 30)
  local operator_target = find_target(operator_screen, function(target)
    return target.id == "modal:chain:chooser:2:1"
  end)
  editor.handle_click(state, operator_target.x, operator_target.y, operator_screen)
  assert(chain_field.chooser and chain_field.chooser.kind == "condition_type", "join chooser should lead into condition chooser")

  local chooser_screen = editor.build_screen(state, 100, 30)
  local first_option = find_target(chooser_screen, function(target)
    return target.id == "modal:chain:chooser:2:1"
  end)
  assert(first_option ~= nil, "condition chooser should expose clickable options")
  editor.handle_click(state, first_option.x, first_option.y, chooser_screen)
  assert(#chain_field.groups == 1 and #chain_field.groups[1].conditions == 1, "choosing a time condition should insert the first condition into the first group")

  local after_screen = editor.build_screen(state, 100, 30)
  local plus_target = find_target(after_screen, function(target)
    return target.id == "modal:chain:plus" and target.modal_chain_position and target.modal_chain_position.location == "end"
  end)
  assert(plus_target ~= nil, "existing conditions should expose an add-after plus")
  editor.handle_click(state, plus_target.x, plus_target.y, after_screen)
  assert(chain_field.chooser and chain_field.chooser.kind == "operator", "adding after a condition should open the operator chooser first")

  local next_operator_screen = editor.build_screen(state, 100, 30)
  local and_target = find_target(next_operator_screen, function(target)
    return target.id == "modal:chain:chooser:2:1"
  end)
  editor.handle_click(state, and_target.x, and_target.y, next_operator_screen)
  assert(chain_field.chooser and chain_field.chooser.kind == "condition_type", "operator choice should be followed by the condition chooser")
end

do
  local state = editor.new_state()
  state.book.STATIONS.mine = {
    display_name = "Mine",
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a"},
    },
  }
  state.book.ROUTES.ore = {waypoints = {"mid", "mine"}}
  local chain_field = editor.make_condition_chain_field({
    cyclic = false,
    entries = {
      {
        route = "ore",
        wait = {
          groups = {
            {
              {
                type = "cargo_percent",
                comparator = ">=",
                value = 90,
                scope = "station_any_detector",
              },
            },
          },
        },
      },
    },
  })
  state.modal = {
    title = "Edit Schedule",
    fields = {editor.make_text_field({key = "route", label = "Route", value = "ore"}), chain_field},
    active_row = 1,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  local rows = editor.build_modal_rows(state.modal)
  local saw_comparator = false
  local saw_value = false
  local saw_scope = false
  local saw_seconds = false
  for _, row in ipairs(rows) do
    if row.kind == "chain_condition_detail" and row.detail == "comparator" then saw_comparator = true end
    if row.kind == "chain_condition_detail" and row.detail == "value" then saw_value = true end
    if row.kind == "chain_condition_detail" and row.detail == "scope" then saw_scope = true end
    if row.kind == "chain_condition_detail" and row.detail == "seconds" then saw_seconds = true end
  end
  assert(saw_comparator and saw_value and saw_scope, "comparator conditions should expose comparator, value, and scope details")
  assert(saw_seconds == false, "comparator conditions should hide the seconds field")

  local type_row_index
  local scope_row_index
  for index, row in ipairs(rows) do
    if row.kind == "chain_condition_detail" and row.detail == "type" then type_row_index = index end
    if row.kind == "chain_condition_detail" and row.detail == "scope" then scope_row_index = index end
  end
  state.modal.active_row = type_row_index
  editor.handle_key_down(state, 0, 28)
  assert(chain_field.chooser and chain_field.chooser.kind == "existing_condition_type", "existing conditions should expose a type chooser")
  chain_field.chooser = nil
  state.modal.active_row = scope_row_index
  editor.handle_key_down(state, 0, 28)
  assert(chain_field.chooser and chain_field.chooser.kind == "scope", "scope should be selected from a chooser menu")
  local scope_options = chain_field.chooser.options or {}
  local saw_station_any = false
  for _, option in ipairs(scope_options) do
    if option == "station_any_detector" then
      saw_station_any = true
    end
  end
  assert(saw_station_any == true, "scope chooser should include station scope options")
end

do
  local state = editor.new_state()
  state.book.STATIONS.mine = {
    display_name = "Mine",
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a"},
    },
  }
  state.book.ROUTES.ore = {waypoints = {"mid", "mine"}}
  local rule_field = editor.make_redstone_rules_field(nil, state.book)
  state.modal = {
    title = "Edit Schedule",
    fields = {
      editor.make_text_field({key = "route", label = "Route", value = "ore"}),
      rule_field,
    },
    active_row = 2,
    scroll_y = 0,
    on_submit = function()
      return true
    end,
  }
  local screen = editor.build_screen(state, 100, 30)
  local add_target = find_target(screen, function(target)
    return target.id == "modal:redstone_rule:add:2"
  end)
  assert(add_target ~= nil, "redstone rules should expose an add rule control")
  editor.handle_click(state, add_target.x, add_target.y, screen)
  assert(#rule_field.rules == 1, "redstone rule add should create a rule")
  local rows = editor.build_modal_rows(state.modal)
  local saw_selected_rule = false
  local saw_selected_condition = false
  for _, row in ipairs(rows) do
    if row.kind == "section" and row.label == "Selected Redstone Rule" then saw_selected_rule = true end
    if row.kind == "section" and row.label == "Selected Redstone Condition" then saw_selected_condition = true end
  end
  assert(saw_selected_rule == true, "schedule modal should render selected redstone rule section")
  local output_row_index
  for index, row in ipairs(rows) do
    if row.kind == "redstone_rule_output" then
      output_row_index = index
      break
    end
  end
  state.modal.active_row = output_row_index
  editor.handle_key_down(state, 0, 28)
  local chooser_rows = editor.build_modal_rows(state.modal)
  local saw_loader = false
  for _, row in ipairs(chooser_rows) do
    if row.kind == "choice_chooser" and row.option == "loader" then
      saw_loader = true
    end
  end
  assert(saw_loader == true, "redstone rule output should open chooser from destination station i/os")
end

assert(editor.group_label(1) == "A", "group_label should format 1 as A")
assert(editor.group_label(26) == "Z", "group_label should format 26 as Z")
assert(editor.group_label(27) == "AA", "group_label should format 27 as AA")
assert(editor.group_label(52) == "AZ", "group_label should format 52 as AZ")
assert(editor.group_label(53) == "BA", "group_label should format 53 as BA")

do
  local repaired = editor.split_legacy_waypoint_string("[427,64,-148],[398,64,-210]")
  assert(#repaired == 2, "legacy waypoint strings should split into separate rows")
  local collected = editor.collect_waypoints({
    waypoints = {"427,64,-148", "[398,64,-210]", "Depot"},
  })
  assert(type(collected[1]) == "table" and collected[1].x == 427 and collected[1].z == -148, "coordinate rows should parse into xyz tables")
  assert(type(collected[2]) == "table" and collected[2].x == 398 and collected[2].z == -210, "bracketed coordinate rows should parse into xyz tables")
  assert(collected[3] == "Depot", "non-coordinate waypoint rows should stay strings")
  local detector_ids = editor.collect_detector_ids({
    detector_ids = {"  north ", "", "south"},
  })
  assert(#detector_ids == 2 and detector_ids[1] == "north" and detector_ids[2] == "south", "detector id rows should trim blanks and discard empties")
end

do
  local runtime_info = editor.inspect_redstone_runtime({
    STATIONS = {
      mine = {
        redstone_outputs = {
          loader = {address = "redstone-a", side = "north", strength = 12, pulse_ticks = 10, active_high = false},
        },
      },
    },
    SCHEDULES = {
      ore_loop = {
        entries = {
          {
            wait = {
              groups = {
                {
                  {
                    type = "time_passed",
                    seconds = 5,
                    redstone = {output = "loader", mode = "while_pending"},
                  },
                },
              },
            },
          },
        },
      },
    },
  })
  assert(runtime_info.required == true, "redstone runtime inspection should mark configured outputs as required")
  assert(#runtime_info.outputs == 1 and runtime_info.outputs[1].output == "loader", "redstone runtime inspection should list configured outputs")
  assert(#runtime_info.condition_refs == 1 and runtime_info.condition_refs[1].mode == "while_pending", "redstone runtime inspection should list schedule redstone references")
  local rows = editor.redstone_output_rows_from_station({
    redstone_outputs = {
      loader = {address = "redstone-a", side = "north", strength = 15, pulse_ticks = 20, active_high = true},
    },
  })
  assert(#rows == 1 and rows[1].id == "loader" and rows[1].address == "redstone-a", "station redstone outputs should round-trip into modal rows")
  local ok_outputs, err_outputs = editor.validate_redstone_output_rows({
    {id = "loader"},
    {id = "loader"},
  })
  assert(ok_outputs == false and tostring(err_outputs):find("duplicated", 1, true) ~= nil, "duplicate redstone output names should be rejected")
end

do
  local wrapped = editor.wrap_text("alpha beta superlongtokenvalue", 8)
  assert(#wrapped >= 3, "wrap_text should expand long panel text into multiple lines")
  assert(wrapped[1] == "alpha", "wrap_text should keep whole words when they fit")
  assert(wrapped[2] == "beta", "wrap_text should continue with the next word on a new line when needed")

  local inline_with_cursor = ({editor.inline_view("abcdef", 4, 0, 4, true)})[1]
  local inline_without_cursor = ({editor.inline_view("abcdef", 4, 0, 4, false)})[1]
  assert(inline_with_cursor:find("|", 1, true) ~= nil, "inline_view should show a cursor when requested")
  assert(inline_without_cursor:find("|", 1, true) == nil, "inline_view should omit the cursor on inactive rows")
end

local saw_tab = false
local saw_button = false
for _, target in ipairs(screen.targets) do
  if target.tab_index == 1 then
    saw_tab = true
  end
  if target.id == "add" then
    saw_button = true
  end
end

assert(saw_tab == true, "editor should render tab targets")
assert(saw_button == true, "editor should render action buttons")

for _, variant in ipairs({screen, medium_screen, compact_screen}) do
  for _, target in ipairs(variant.targets) do
    assert(type(target.x) == "number" and target.x >= 1, "all targets should have numeric x")
    assert(type(target.y) == "number" and target.y >= 1, "all targets should have numeric y")
    assert(type(target.width) == "number" and target.width > 0, "all targets should have positive width")
    assert(type(target.height) == "number" and target.height > 0, "all targets should have positive height")
  end
end

local gpu_writes = {}
local fake_gpu = {
  fill = function() end,
  set = function(x, y, line)
    gpu_writes[#gpu_writes + 1] = {x = x, y = y, line = line}
  end,
}
ui._frame_cache = nil
local flush_ok = ui.flush(nil, fake_gpu, 10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
}, 4, 2)
assert(flush_ok == true, "flush should succeed with a bound gpu")
assert(#gpu_writes >= 2, "flush should write frame lines through gpu.set when available")
assert(gpu_writes[1].x == 4 and gpu_writes[1].y == 2, "flush should honor the terminal origin")

local term_writes = {}
local fake_term = {
  clear = function() end,
  setCursor = function(x, y)
    term_writes[#term_writes + 1] = {kind = "cursor", x = x, y = y}
  end,
  write = function(line)
    term_writes[#term_writes + 1] = {kind = "write", line = line}
  end,
}
ui._frame_cache = nil
local fallback_ok, fallback_err = ui.flush(fake_term, nil, 10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
}, 4, 2)
assert(fallback_ok == nil, "flush should reject framebuffer rendering without a gpu")
assert(tostring(fallback_err):find("gpu", 1, true) ~= nil, "flush should explain the missing gpu")
assert(#term_writes == 0, "flush should not use term.write for fullscreen ui frames")
local truth_lines = ui.render_lines(10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
})
assert(gpu_writes[1].line == truth_lines[1], "gpu flush should use render_lines frame content")
assert(gpu_writes[2].line == truth_lines[2], "gpu flush should keep render_lines line order")
required_ui._frame_cache = {width = 1, height = 1, origin_x = 1, origin_y = 1, lines = {"x"}}
required_ui.reset_cache()
assert(required_ui._frame_cache == nil, "reset_cache should clear the frame cache")

local bound_gpu = {
  set = function() end,
  fill = function() end,
  getResolution = function()
    return 160, 50
  end,
}
local terminal_context = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 4, 2, 54, 18
  end,
}, {
  gpu = function()
    return bound_gpu
  end,
  getViewport = function()
    return 54, 18, 0, 0, 1, 1
  end,
})
assert(terminal_context.renderer == "term-gpu", "editor should prefer the bound terminal gpu")
assert(terminal_context.viewport_width == 54 and terminal_context.viewport_height == 18, "editor should size layouts from the visible viewport")
assert(terminal_context.origin_x == 4 and terminal_context.origin_y == 2, "editor should preserve the terminal origin")
assert(terminal_context.physical_width == 160 and terminal_context.physical_height == 50, "editor should preserve physical gpu size as diagnostic info")
assert(editor.build_screen(state, terminal_context.viewport_width, terminal_context.viewport_height).layout.tier == "compact", "viewport size should control layout tier")
local terminal_diag = editor.diagnostic_summary(terminal_context)
assert(terminal_diag:find("renderer=term%-gpu") ~= nil, "diagnostics should report the terminal renderer")
assert(terminal_diag:find("viewport=54x18", 1, true) ~= nil, "diagnostics should report the viewport size")
assert(terminal_diag:find("origin=4,2", 1, true) ~= nil, "diagnostics should report the terminal origin")
assert(terminal_diag:find("raw_viewport=54,18,0,0,1,1", 1, true) ~= nil, "diagnostics should report the raw viewport tuple")
assert(terminal_diag:find("gpu=160x50", 1, true) ~= nil, "diagnostics should report the physical gpu size")
assert(terminal_diag:find("out of date", 1, true) == nil, "diagnostics should not claim term_ui is out of date")
assert(terminal_diag:find("tty_module=yes", 1, true) ~= nil, "diagnostics should report tty module presence")
assert(terminal_diag:find("tty_gpu=yes", 1, true) ~= nil, "diagnostics should report tty gpu presence")

do
  local startup_state = editor.new_state()
  local original_message = startup_state.message
  editor.apply_startup_status(startup_state, terminal_context, nil, {}, "run")
  assert(startup_state.message == original_message, "normal startup should keep the editor status line intact")

  local diagnose_message = editor.startup_summary(terminal_context, nil, {mode_name = "diagnose-ui"})
  assert(diagnose_message:find("renderer=term%-gpu") ~= nil, "diagnose-ui should still expose full diagnostics")
end

do
  local save_state = editor.new_state()
  save_state.active_tab = 5
  save_state.book.STATIONS.mine = {
    display_name = "Mine",
    x = 1, y = 64, z = 1,
    detector_ids = {},
    redstone_outputs = {
      loader = {address = "redstone-a", side = "north", strength = 15, pulse_ticks = 20, active_high = true},
    },
  }
  save_state.book.SCHEDULES.loop = {
    cyclic = false,
    entries = {
      {
        route = "ore",
        wait = {
          groups = {
            {
              {
                type = "time_passed",
                seconds = 0,
                redstone = {output = "loader", mode = "while_pending"},
              },
            },
          },
        },
      },
    },
  }
  local save_screen = editor.build_screen(save_state, 100, 30)
  local save_lines = ui.render_lines(100, 30, save_screen.buffer)
  local save_text = table.concat(save_lines, "\n")
  assert(save_text:find("Run schedule: station_dispatch run <schedule>", 1, true) ~= nil, "save tab should show schedule runtime help")
  assert(save_text:find("Run route: train_controller route <route>", 1, true) ~= nil, "save tab should show direct route help")
  assert(save_text:find("Schedules run on the active ir_remote_control train.", 1, true) ~= nil, "save tab should explain runtime schedule ownership")
  assert(save_text:find("Redstone runtime: required", 1, true) ~= nil, "save tab should show redstone runtime requirements")
  assert(save_text:find("Schedule redstone binds by I/O ID to the destination station.", 1, true) ~= nil, "save tab should explain redstone schedule binding by I/O id")
  assert(save_text:find("Station I/O address selects which redstone module is used.", 1, true) ~= nil, "save tab should explain station io addresses")
  assert(save_text:find("Conditions in a group are AND.", 1, true) ~= nil, "save tab should explain AND semantics")
  assert(save_text:find("Groups are OR.", 1, true) ~= nil, "save tab should explain OR semantics")
  assert(save_text:find("Click [+] to add a condition, then choose AND or OR before the next one.", 1, true) ~= nil, "save tab should explain the add-and-choose flow")
  assert(save_text:find("Comparator-based conditions open a comparator chooser before returning.", 1, true) ~= nil, "save tab should explain comparator chooser behavior")
  assert(save_text:find("Wait controls departure. Redstone rules are separate.", 1, true) ~= nil, "save tab should explain split wait/redstone logic")
  assert(save_text:find("Redstone rule outputs come from the route destination station I/Os.", 1, true) ~= nil, "save tab should explain redstone rule outputs")
  assert(save_text:find("read-only here", 1, true) == nil, "save tab should no longer claim that redstone outputs are read-only")
  assert(save_text:find("uses redstone: loop entry 1 -> loader (while_pending)", 1, true) ~= nil, "save tab should summarize redstone-linked wait conditions")
end

do
  local wrap_state = editor.new_state()
  local buffer = {}
  local info = editor.render_wrapped_lines(buffer, 1, 1, 8, 2, {"alpha beta superlongtokenvalue"}, 0)
  local lines = ui.render_lines(8, 2, buffer)
  assert(info.line_count == 5 and info.max_scroll == 3, "render_wrapped_lines should expand wrapped text and report scroll bounds")
  assert(lines[1]:find("alpha", 1, true) ~= nil, "wrapped renderer should keep the first readable line")
  assert(lines[2]:find("beta", 1, true) ~= nil, "wrapped renderer should continue on following lines without clipping markers")
end

do
  local modal_state = editor.new_state()
  local field = editor.make_repeatable_text_field({
    key = "waypoints",
    label = "Waypoints",
    values = {"427,64,-148", "398,64,-210"},
    min_items = 1,
  })
  local active_row = editor.build_modal_rows({
    fields = {field},
    active_row = 1,
  })[1]
  local inactive_row = editor.build_modal_rows({
    fields = {field},
    active_row = 2,
  })[2]
  local active_text = editor.inline_view(active_row.item.value, active_row.item.cursor, active_row.item.scroll_x, 12, true)
  local inactive_text = editor.inline_view(inactive_row.item.value, inactive_row.item.cursor, inactive_row.item.scroll_x, 12, false)
  assert(({active_text})[1]:find("|", 1, true) ~= nil, "active modal rows should show a cursor")
  assert(({inactive_text})[1]:find("|", 1, true) == nil, "inactive modal rows should not show a cursor")
end

local termless_context = editor.resolve_terminal_context({
  getGlobalArea = function()
    return 9, 3, 54, 18
  end,
}, {
  gpu = function()
    return bound_gpu
  end,
  getViewport = function()
    return 54, 18, 0, 0, 1, 1
  end,
})
assert(termless_context ~= nil, "editor should succeed when tty.gpu is valid even if term.gpu is missing")
assert(termless_context.viewport_width == 54 and termless_context.viewport_height == 18, "6-value viewport results should still parse width and height")

local missing_gpu_context, missing_gpu_error, missing_gpu_diag = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 1, 1, 80, 25
  end,
}, {
  getViewport = function()
    return 80, 25, 0, 0, 1, 1
  end,
})
assert(missing_gpu_context == nil, "editor should reject a terminal without a bound gpu")
assert(missing_gpu_error == "no gpu component", "missing gpu should surface as a specific startup error")
assert(missing_gpu_diag.term_gpu == "yes", "diagnostics should keep term.gpu separate from tty.gpu")
assert(missing_gpu_diag.tty_gpu == "no", "diagnostics should show the missing tty gpu")

do
  local tty_state = {gpu = nil}
  local weird_gpu = setmetatable({}, {
    __index = {
      getScreen = function()
        return "screen-2"
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
  })
  local proxy_context, proxy_problem, proxy_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return weird_gpu
      end
      if kind == "screen" then
        return {address = "screen-1"}
      end
    end,
  })
  assert(proxy_context ~= nil and proxy_problem == nil, "resolver should accept readable proxies independent of raw basetype assumptions")
  assert(proxy_diag.gpu_proxy_type ~= "nil", "diagnostics should report the detected gpu proxy type")
  assert(proxy_diag.gpu_has_bind == "yes" and proxy_diag.gpu_has_getScreen == "yes", "diagnostics should report readable proxy methods")
end

do
  local tty_state = {gpu = nil}
  local invoke_gpu = {address = "gpu-proxy"}
  local invoke_screen = {address = "screen-1"}
  local component_api = {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return invoke_gpu
      end
      if kind == "screen" then
        return invoke_screen
      end
    end,
    invoke = function(address, method, ...)
      if address == "gpu-proxy" and method == "getScreen" then
        return "screen-2"
      end
      if address == "gpu-proxy" and method == "getResolution" then
        return 160, 50
      end
      if address == "gpu-proxy" and method == "bind" then
        return true
      end
    end,
  }
  local invoke_context, invoke_problem, invoke_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, component_api)
  assert(invoke_context ~= nil and invoke_problem == nil, "resolver should accept proxies whose methods are only reachable through component.invoke")
  assert(invoke_diag.invoke_getScreen_ok == "yes", "diagnostics should report invoke-based getScreen support")
  assert(invoke_diag.invoke_set_ok == "yes", "diagnostics should report invoke-based set support")
end

local missing_tty_context, missing_tty_error, missing_tty_diag = editor.resolve_terminal_context({
  gpu = function()
    return bound_gpu
  end,
  getGlobalArea = function()
    return 1, 1, 80, 25
  end,
}, nil)
assert(missing_tty_context == nil, "editor should reject missing tty module")
assert(missing_tty_error == "tty unavailable", "editor should report missing tty separately")
assert(missing_tty_diag.tty_module == false, "diagnostics should record absent tty module")
assert(editor.diagnostic_summary(nil, missing_tty_error, missing_tty_diag):find("renderer=unavailable", 1, true) ~= nil, "diagnostic mode should still emit a summary without context")

do
  local component_gpu = {}
  component_gpu.address = "gpu-1"
  component_gpu.getScreen = function()
    return component_gpu._bound or "screen-2"
  end
  component_gpu.bind = function(screen_address)
    component_gpu._bound = screen_address
    return true
  end
  component_gpu.getResolution = function()
    return 160, 50
  end
  component_gpu.set = function() end
  component_gpu.fill = function() end

  local tty_state = {gpu = nil}
  local rebound_context, rebound_problem, rebound_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    isAvailable = function()
      return true
    end,
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.gpu = gpu
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = component_gpu,
    screen = {address = "screen-1"},
  })
  assert(rebound_context ~= nil and rebound_problem == nil, "resolver should recover from a missing tty bind")
  assert(component_gpu._bound == nil, "existing gpu/screen binds should not be replaced when tty.bind is enough")
  assert(rebound_diag.rebind_attempted == "yes", "diagnostics should record the rebind attempt")
  assert(rebound_diag.rebind_ok == "yes", "diagnostics should report a successful rebind")
  assert(rebound_diag.tty_gpu_before == "no", "diagnostics should record the missing tty gpu before repair")
  assert(rebound_diag.tty_gpu_after == "yes", "diagnostics should record the repaired tty gpu")
  assert(rebound_diag.gpu_current_screen == "screen-2", "diagnostics should report the pre-existing gpu screen bind")
  assert(rebound_diag.tty_bind_before_gpu_bind == "yes", "diagnostics should record the early tty bind attempt")
  assert(rebound_diag.gpu_bind_attempted == "no", "diagnostics should not bind the gpu when tty.bind already fixes the state")
  assert(editor.diagnostic_summary(rebound_context):find("rebind_attempted=yes", 1, true) ~= nil, "summary should expose rebind flags")
end

do
  local component_gpu = {}
  component_gpu.address = "gpu-1"
  component_gpu.getScreen = function()
    return component_gpu._bound
  end
  component_gpu.bind = function(screen_address)
    component_gpu._bound = screen_address
    return true
  end
  component_gpu.getResolution = function()
    return 160, 50
  end
  component_gpu.set = function() end
  component_gpu.fill = function() end

  local tty_state = {gpu = nil, attempts = 0}
  local rebound_context, rebound_problem, rebound_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return tty_state.gpu
    end,
    bind = function(gpu)
      tty_state.attempts = tty_state.attempts + 1
      if tty_state.attempts >= 2 then
        tty_state.gpu = gpu
      end
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = component_gpu,
    screen = {address = "screen-1"},
  })
  assert(rebound_context ~= nil and rebound_problem == nil, "resolver should recover after gpu.bind plus tty.bind when the gpu has no screen")
  assert(component_gpu._bound == "screen-1", "gpu.bind should run when the gpu has no screen")
  assert(rebound_diag.gpu_bind_attempted == "yes", "diagnostics should record the gpu bind attempt")
  assert(rebound_diag.gpu_bind_ok == "yes", "diagnostics should record a successful gpu bind")
  assert(rebound_diag.tty_bind_after_gpu_bind == "yes", "diagnostics should record the second tty bind attempt")
end

do
  local no_screen_context, no_screen_error, no_screen_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu"
    end,
    gpu = {
      getScreen = function()
        return nil
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
  })
  assert(no_screen_context == nil, "resolver should fail when no screen component exists")
  assert(no_screen_error == "no screen component", "missing screen should surface as a specific startup error")
  assert(no_screen_diag.component_screen == "no", "diagnostics should report missing screen component")
end

do
  local bad_proxy_context, bad_proxy_error, bad_proxy_diag = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    getPrimary = function(kind)
      if kind == "gpu" then
        return {}
      end
      if kind == "screen" then
        return {address = "screen-1"}
      end
    end,
  })
  assert(bad_proxy_context == nil, "resolver should fail when the gpu proxy is unreadable")
  assert(bad_proxy_error == "gpu invoke unavailable", "unreadable gpu proxies should not be misreported as gpu bind failures")
  assert(editor.diagnostic_summary(nil, bad_proxy_error, bad_proxy_diag):find("gpu_proxy_type=table", 1, true) ~= nil, "diagnostics should expose proxy-type failures")
end

do
  local bind_fail_context, bind_fail_error = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return true
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = {
      getScreen = function()
        return nil
      end,
      bind = function()
        return false, "bind failed"
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
    screen = {address = "screen-1"},
  })
  assert(bind_fail_context == nil and bind_fail_error == "gpu has no screen and gpu bind failed", "gpu bind errors should only surface when the gpu truly has no screen")
end

do
  local tty_bind_fail_context, tty_bind_fail_error = editor.resolve_terminal_context({
    getGlobalArea = function()
      return 4, 2, 54, 18
    end,
  }, {
    gpu = function()
      return nil
    end,
    bind = function()
      return false, "tty bind failed"
    end,
    getViewport = function()
      return 54, 18, 0, 0, 1, 1
    end,
  }, {
    isAvailable = function(kind)
      return kind == "gpu" or kind == "screen"
    end,
    gpu = {
      getScreen = function()
        return "screen-1"
      end,
      bind = function()
        return true
      end,
      getResolution = function()
        return 160, 50
      end,
      set = function() end,
      fill = function() end,
    },
    screen = {address = "screen-1"},
  })
  assert(tty_bind_fail_context == nil and tty_bind_fail_error == "tty bind failed", "tty bind errors should be surfaced explicitly")
end

do
  local original_require = require
  local original_global_term = _G.term
  local old_term_ui = {
    box = ui.box,
    button = ui.button,
    render_box = ui.render_box,
    render_tabs = ui.render_tabs,
    render_list = ui.render_list,
    render_buttons = ui.render_buttons,
    flush = ui.flush,
    fit_text = ui.fit_text,
    hit = ui.hit,
  }

  _G.require = function(name)
    if name == "lib.term_ui" then
      return old_term_ui
    end
    if name == "term" then
      return {
        gpu = function()
          return nil
        end,
        getGlobalArea = function()
          return 1, 1, 54, 18
        end,
      }
    end
    if name == "tty" then
      return {
        gpu = function()
          return bound_gpu
        end,
        getViewport = function()
          return 54, 18, 0, 0, 1, 1
        end,
      }
    end
    return original_require(name)
  end
  _G.term = {
    gpu = function()
      error("polluted global term should not be used")
    end,
  }

  local mixed_editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local mixed_state = mixed_editor.new_state()
  local mixed_screen = mixed_editor.build_screen(mixed_state, 100, 30)
  assert(type(mixed_screen.targets) == "table" and #mixed_screen.targets > 0, "new editor should tolerate old term_ui without is_valid_target")
  local mixed_context, mixed_problem = mixed_editor.resolve_terminal_context(require("term"), require("tty"))
  assert(mixed_context ~= nil and mixed_problem == nil, "resolver should use required modules instead of polluted globals")

  _G.require = original_require
  _G.term = original_global_term
end

do
  local offset_writes = {}
  local offset_gpu = {
    fill = function(x, y, width, height, char)
      offset_writes[#offset_writes + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
    end,
    set = function(x, y, line)
      offset_writes[#offset_writes + 1] = {kind = "set", x = x, y = y, line = line}
    end,
  }
  ui._frame_cache = nil
  local ok = ui.flush(nil, offset_gpu, 12, 2, {
    {x = 1, y = 1, text = "hello"},
    {x = 1, y = 2, text = "world"},
  }, 4, 2)
  assert(ok == true, "offset flush should succeed")
  assert(offset_writes[1].kind == "fill" and offset_writes[1].x == 4 and offset_writes[1].y == 2, "clear should respect terminal origin")
  assert(offset_writes[2].kind == "set" and offset_writes[2].x == 4 and offset_writes[2].y == 2, "first rendered line should use origin offset")
  assert(offset_writes[3].kind == "set" and offset_writes[3].x == 4 and offset_writes[3].y == 3, "second rendered line should stack under origin")
end

do
  local cleanup_calls = {}
  local cleanup_gpu = {
    fill = function(x, y, width, height, char)
      cleanup_calls[#cleanup_calls + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
    end,
    set = function(x, y, line)
      cleanup_calls[#cleanup_calls + 1] = {kind = "set", x = x, y = y, line = line}
    end,
  }
  local original_require = require
  local cursor_calls = {}
  _G.require = function(name)
    if name == "term" then
      return {
        setCursor = function(x, y)
          cursor_calls[#cursor_calls + 1] = {x = x, y = y}
        end,
      }
    end
    return original_require(name)
  end
  local cleanup_editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")
  local cleanup_ui = package.loaded["lib.term_ui"]
  cleanup_ui._frame_cache = {width = 12, height = 2, origin_x = 4, origin_y = 2, lines = {"hello", "world"}}
  local ok = cleanup_editor.finalize_exit({
    gpu = cleanup_gpu,
    viewport_width = 12,
    viewport_height = 2,
    origin_x = 4,
    origin_y = 2,
  }, {kind = "interrupted"})
  _G.require = original_require
  assert(ok == true, "finalize_exit should treat interrupted exits as controlled success")
  assert(cleanup_ui._frame_cache == nil, "finalize_exit should reset the ui frame cache")
  assert(#cleanup_calls > 0, "finalize_exit should actively clear the editor viewport")
  assert(cursor_calls[1] and cursor_calls[1].x == 1 and cursor_calls[1].y == 1, "finalize_exit should restore the cursor")
end

do
  local terminated = editor.normalize_runtime_failure({reason = "terminated", code = 130})
  assert(terminated.kind == "terminated" and terminated.code == 130, "terminated tables should be normalized into controlled exits")
  local exploded = editor.normalize_runtime_failure("boom")
  assert(exploded.kind == "error" and exploded.message == "boom", "plain runtime errors should stay errors")
end

do
  local original_require = require
  local invoke_writes = {}
  _G.require = function(name)
    if name == "component" then
      return {
        invoke = function(address, method, ...)
          if address == "gpu-fallback" and method == "fill" then
            local x, y, width, height, char = ...
            invoke_writes[#invoke_writes + 1] = {kind = "fill", x = x, y = y, width = width, height = height, char = char}
            return true
          end
          if address == "gpu-fallback" and method == "set" then
            local x, y, line = ...
            invoke_writes[#invoke_writes + 1] = {kind = "set", x = x, y = y, line = line}
            return true
          end
        end,
      }
    end
    return original_require(name)
  end
  local invoke_ui = assert(loadfile("./programs/lib/term_ui.lua"))()
  invoke_ui._frame_cache = nil
  local ok = invoke_ui.flush(nil, {address = "gpu-fallback"}, 8, 2, {
    {x = 1, y = 1, text = "abc"},
    {x = 1, y = 2, text = "def"},
  }, 3, 4)
  assert(ok == true, "term_ui should support invoke-based gpu proxies")
  assert(invoke_writes[1].kind == "fill" and invoke_writes[1].x == 3 and invoke_writes[1].y == 4, "invoke fallback should clear using the translated origin")
  assert(invoke_writes[2].kind == "set" and invoke_writes[2].x == 3 and invoke_writes[2].y == 4, "invoke fallback should write the first line at the translated origin")
  _G.require = original_require
end

do
  local local_x, local_y = editor.normalize_pointer_event({
    screen_address = "screen-1",
    origin_x = 4,
    origin_y = 2,
    viewport_width = 54,
    viewport_height = 18,
  }, "screen-1", 7, 4)
  assert(local_x == 4 and local_y == 3, "pointer events should be translated into viewport-local coordinates")

  local ignored_x = editor.normalize_pointer_event({
    screen_address = "screen-1",
    origin_x = 4,
    origin_y = 2,
    viewport_width = 54,
    viewport_height = 18,
  }, "other-screen", 7, 4)
  assert(ignored_x == nil, "pointer events from other screens should be ignored")
end

print("term_ui_preview ok")
