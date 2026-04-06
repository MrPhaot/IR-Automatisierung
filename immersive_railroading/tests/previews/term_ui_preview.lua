package.path = "./programs/?.lua;./programs/lib/?.lua;" .. package.path

local ui = assert(loadfile("./programs/lib/term_ui.lua"))()
local editor = assert(loadfile("./programs/route_book_editor.lua"))("__module__")

local state = editor.new_state()
local screen = editor.build_screen(state, 100, 30)

assert(type(screen.buffer) == "table" and #screen.buffer > 0, "editor should render a screen buffer")
assert(type(screen.targets) == "table" and #screen.targets > 0, "editor should expose clickable targets")
assert(ui.hit({x = 1, y = 1, width = 5, height = 2}, 3, 2) == true, "hit testing should work")
assert(ui.fit_text("abcdef", 4) == "abc>", "fit_text should mark truncation")

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

print("term_ui_preview ok")
