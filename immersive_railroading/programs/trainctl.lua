local controller, load_error = loadfile("train_controller.lua")
if not controller then
  controller, load_error = loadfile("programs/train_controller.lua")
end
if not controller then
  io.stderr:write("failed to load train_controller.lua: " .. tostring(load_error) .. "\n")
  os.exit(1)
end

local module = controller("__module__")
local ok, err = module.main({...})
if ok == nil then
  io.stderr:write(tostring(err) .. "\n")
  os.exit(1)
end
