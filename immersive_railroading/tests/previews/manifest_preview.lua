local root = ...
if not root or root == "" then
  root = "."
end

local manifest = assert(loadfile(root .. "/programs/install_manifest.lua"))()
local installer = assert(loadfile(root .. "/programs/install.lua"))()

assert(type(manifest.version) == "string" and manifest.version ~= "", "missing manifest version")
assert(type(manifest.files) == "table" and #manifest.files > 0, "manifest has no files")

local ok, err = installer.validate_manifest(manifest)
assert(ok, err)

print(("manifest ok: version=%s files=%d"):format(manifest.version, #manifest.files))
