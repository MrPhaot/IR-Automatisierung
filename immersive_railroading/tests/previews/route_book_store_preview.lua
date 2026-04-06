local function split_path(path)
  local directory = path:match("^(.*)/[^/]+$")
  return directory or "."
end

local function join_paths(base, child)
  if base == "." or base == "" then
    return child
  end
  return base .. "/" .. child
end

local preview_dir = split_path(debug.getinfo(1, "S").source:sub(2))
local store = assert(loadfile(join_paths(preview_dir, "../../programs/lib/route_book_store.lua")))()

local book = store.canonicalize({
  STATIONS = {
    ["1"] = {x = 1, y = 2, z = 3},
  },
})

assert(book.AUGMENTS.DETECTORS ~= nil, "canonicalize should add AUGMENTS.DETECTORS")
assert(type(store.serialize(book)) == "string", "serialize should return Lua source")

local temp_path = "/tmp/ir_route_book_store_preview.lua"
local ok, err = store.save(temp_path, book)
assert(ok, err)

local loaded, load_error = store.load(temp_path)
assert(loaded, load_error)
assert(loaded.STATIONS["1"].x == 1, "saved route book should round-trip")

print("route_book_store_preview ok")
