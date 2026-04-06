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
local module = assert(loadfile(join_paths(preview_dir, "../../programs/lib/augment_registry.lua")))()

local book = {
  AUGMENTS = {
    DETECTORS = {
      mine_front = {address = "addr-1", label = "Mine Front", sort_order = 20},
      yard_mid = {address = "addr-2", label = "Yard Mid", sort_order = 10},
    },
  },
  STATIONS = {
    ["1"] = {detector_ids = {"mine_front"}},
  },
}

local items = module.list(book)
assert(items[1].id == "yard_mid", "detectors should sort by sort_order")

local result = module.validate(book)
assert(result.ok == true, "valid detector registry should pass")

local changed = select(1, module.merge_scan(book, {{address = "addr-3"}}))
assert(changed == true, "new detector from scan should be merged")
assert(module.address_index(book)["addr-3"] ~= nil, "merged detector should be address-indexed")

local bad = {
  AUGMENTS = {DETECTORS = {
    a = {address = "dup"},
    b = {address = "dup"},
  }},
  STATIONS = {["1"] = {detector_ids = {"a", "b"}}, ["2"] = {detector_ids = {"a"}}},
}
local invalid = module.validate(bad)
assert(invalid.ok == false, "duplicate detector address should fail validation")

print("augment_registry_preview ok")
