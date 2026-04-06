package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local ui = assert(loadfile("./programs/lib/term_ui.lua"))()
local editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")

local state = editor.new_state()
local screen = editor.build_screen(state, 100, 30)
local compact_screen = editor.build_screen(state, 54, 18)
local minimum_screen = editor.build_screen(state, 50, 16)

assert(type(screen.buffer) == "table" and #screen.buffer > 0, "editor should render a screen buffer")
assert(type(screen.targets) == "table" and #screen.targets > 0, "editor should expose clickable targets")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, 2) == true, "hit testing should work")
assert(ui.hit(nil, 3, 2) == false, "hit should ignore nil rects")
assert(ui.hit({x = 1, y = 1, width = nil, height = 2}, 3, 2) == false, "hit should ignore nil width")
assert(ui.hit({x = 1, y = 1, width = 5, height = nil}, 3, 2) == false, "hit should ignore nil height")
assert(ui.hit({x = 1, y = 1, width = 0, height = 2}, 3, 2) == false, "hit should reject zero width")
assert(ui.hit({x = 1, y = 1, width = 5, height = 0}, 3, 2) == false, "hit should reject zero height")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, nil, 2) == false, "hit should reject nil px")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, nil) == false, "hit should reject nil py")
assert(ui.fit_text("abcdef", 4) == "abc>", "fit_text should mark truncation")
assert(compact_screen.layout.tier == "compact", "54x18 should use compact layout")
assert(minimum_screen.layout.tier == "minimum", "50x16 should use minimum-size fallback")

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

for _, variant in ipairs({screen, compact_screen}) do
  for _, target in ipairs(variant.targets) do
    assert(type(target.x) == "number" and target.x >= 1, "all targets should have numeric x")
    assert(type(target.y) == "number" and target.y >= 1, "all targets should have numeric y")
    assert(type(target.width) == "number" and target.width > 0, "all targets should have positive width")
    assert(type(target.height) == "number" and target.height > 0, "all targets should have positive height")
  end
end

local writes = {}
local fake_gpu = {
  fill = function() end,
  set = function(_, x, y, line)
    writes[#writes + 1] = {x = x, y = y, line = line}
  end,
}
ui.flush(nil, fake_gpu, 10, 3, {
  {x = 1, y = 1, text = "header"},
  {x = 1, y = 2, text = "body"},
})
assert(#writes >= 2, "flush should write frame lines through gpu.set when available")
assert(writes[1].x == 1, "flush should write full lines from column 1")

print("term_ui_preview ok")
