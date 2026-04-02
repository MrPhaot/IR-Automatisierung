local installer, load_error = loadfile("programs/install.lua")
if not installer then
  installer, load_error = loadfile("install.lua")
end
if not installer then
  io.stderr:write("failed to load install.lua: " .. tostring(load_error) .. "\n")
  os.exit(1)
end

local module = installer("__module__")
module.main()
