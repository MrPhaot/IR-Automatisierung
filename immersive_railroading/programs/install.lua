local function fail(message)
  io.stderr:write(message .. "\n")
  os.exit(1)
end

local function validate_relative_path(path)
  if type(path) ~= "string" or path == "" then
    return nil, "path must be a non-empty string"
  end
  if path:sub(1, 1) == "/" then
    return nil, "absolute paths are not allowed: " .. path
  end
  if path:find("%.%.", 1, false) then
    return nil, "path traversal is not allowed: " .. path
  end
  return true
end

local function validate_manifest(manifest)
  if type(manifest) ~= "table" then
    return nil, "manifest must return a table"
  end
  if type(manifest.version) ~= "string" or manifest.version == "" then
    return nil, "manifest.version must be a non-empty string"
  end
  if type(manifest.files) ~= "table" then
    return nil, "manifest.files must be a table"
  end

  local seen = {}
  for index, entry in ipairs(manifest.files) do
    if type(entry) ~= "table" then
      return nil, ("manifest.files[%d] must be a table"):format(index)
    end

    local ok, path_error = validate_relative_path(entry.path)
    if not ok then
      return nil, path_error
    end

    if seen[entry.path] then
      return nil, "duplicate manifest path: " .. entry.path
    end
    seen[entry.path] = true

    if type(entry.url) ~= "string" or not entry.url:match("^https://raw%.githubusercontent%.com/.+") then
      return nil, "unsupported download url for " .. entry.path
    end
  end

  return true
end

local function load_manifest()
  local chunk, load_error = loadfile("programs/install_manifest.lua")
  if not chunk then
    chunk, load_error = loadfile("install_manifest.lua")
  end
  if not chunk then
    fail("failed to load install_manifest.lua: " .. tostring(load_error))
  end

  local manifest = chunk()
  local ok, validate_error = validate_manifest(manifest)
  if not ok then
    fail("invalid manifest: " .. validate_error)
  end
  return manifest
end

local function dirname(path)
  return (path:match("^(.*)/[^/]+$")) or "."
end

local function main()
  local shell = require("shell")
  local fs = require("filesystem")
  local manifest = load_manifest()

  for _, entry in ipairs(manifest.files) do
    local parent = dirname(entry.path)
    if parent ~= "." and not fs.exists(parent) then
      fs.makeDirectory(parent)
    end

    local command = string.format("wget -f %q %q", entry.url, entry.path)
    io.write(("installing %s\n"):format(entry.path))
    local ok, reason = shell.execute(command)
    if ok == nil or ok == false then
      fail(("download failed for %s: %s"):format(entry.path, tostring(reason)))
    end
  end

  io.write(("installed version %s\n"):format(manifest.version))
end

local argv = rawget(_G, "arg") or {}

if type(argv[0]) == "string" and argv[0]:match("install%.lua$") then
  main()
end

return {
  validate_manifest = validate_manifest,
  validate_relative_path = validate_relative_path,
}
