local function is_interrupt_reason(reason)
  reason = tostring(reason or ""):lower()
  return reason:match("interrupted") ~= nil or reason:match("terminated") ~= nil or reason == "terminate"
end

local function normalize_runtime_error(err)
  if type(err) == "table" then
    return err.reason or err.code or err.message or err[1] or tostring(err)
  end
  return tostring(err)
end

local controller, load_error = loadfile("train_controller.lua")
if not controller then
  controller, load_error = loadfile("programs/train_controller.lua")
end
if not controller then
  io.stderr:write("failed to load train_controller.lua: " .. tostring(load_error) .. "\n")
  os.exit(1)
end

local module_ok, module_or_error = pcall(controller, "__module__")
if not module_ok then
  local reason = normalize_runtime_error(module_or_error)
  io.stderr:write(reason .. "\n")
  if is_interrupt_reason(reason) then
    os.exit(130)
  end
  os.exit(1)
end

local module = module_or_error
local call_ok, ok, err = pcall(module.main, {...})
if not call_ok then
  local reason = normalize_runtime_error(ok)
  io.stderr:write(reason .. "\n")
  if reason == "aborted by user" or is_interrupt_reason(reason) then
    os.exit(130)
  end
  os.exit(1)
end

if ok == nil then
  local reason = normalize_runtime_error(err)
  io.stderr:write(reason .. "\n")
  if reason == "aborted by user" or is_interrupt_reason(reason) then
    os.exit(130)
  end
  os.exit(1)
end
