local M = {}

local function is_terminated(err)
  return type(err) == "table" and err.reason == "terminated"
end

function M.load_module(path)
  local chunk = assert(loadfile(path))
  return chunk("__module__")
end

function M.run_program(program, argv, options)
  options = options or {}
  local entry
  if type(program) == "table" then
    entry = program.run or program.main
  elseif type(program) == "function" then
    entry = program
  end
  assert(type(entry) == "function", "program must expose run(argv) or main(argv)")

  local ok, success, err = xpcall(function()
    return entry(argv or {})
  end, debug.traceback)

  local result_ok, result_err
  if not ok then
    result_ok = nil
    result_err = success
  elseif success == nil then
    result_ok = nil
    result_err = err
  else
    result_ok = true
  end

  if options.runtime and options.shell_redraw then
    options.runtime:shell_redraw(result_ok and nil or tostring(result_err))
  end

  return result_ok, result_err
end

function M.run_script(path, argv, options)
  options = options or {}
  local runtime = options.runtime
  local saved_stderr = io.stderr
  local saved_io_write = io.write
  local saved_os_exit = os.exit
  local stderr_lines = {}
  local stdout_lines = {}

  io.stderr = {
    write = function(_, text)
      text = tostring(text or "")
      stderr_lines[#stderr_lines + 1] = text
      if runtime then
        runtime.shell.stderr[#runtime.shell.stderr + 1] = text
      end
      return true
    end,
  }
  io.write = function(...)
    local parts = {}
    for index = 1, select("#", ...) do
      parts[#parts + 1] = tostring(select(index, ...))
    end
    local text = table.concat(parts)
    stdout_lines[#stdout_lines + 1] = text
    if runtime then
      runtime.shell.stdout[#runtime.shell.stdout + 1] = text
    end
    return true
  end

  os.exit = function(code)
    error({
      reason = "terminated",
      code = code or 0,
      message = "terminated",
    }, 0)
  end

  local ok, result, extra = xpcall(function()
    local chunk = assert(loadfile(path))
    return chunk(table.unpack(argv or {}))
  end, function(err)
    return err
  end)

  io.stderr = saved_stderr
  io.write = saved_io_write
  os.exit = saved_os_exit

  local result_ok, result_err, meta
  if ok then
    result_ok = true
    meta = {exit_code = 0, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines)}
  elseif is_terminated(result) then
    if result.code == 0 then
      result_ok = true
      meta = {exit_code = 0, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines)}
    else
      result_ok = nil
      result_err = table.concat(stderr_lines) ~= "" and table.concat(stderr_lines) or tostring(result.message or "terminated")
      meta = {exit_code = result.code, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines), terminated = true}
    end
  else
    result_ok = nil
    result_err = tostring(result)
    meta = {exit_code = 1, stderr = table.concat(stderr_lines), stdout = table.concat(stdout_lines)}
  end

  if runtime and options.shell_redraw then
    runtime:shell_redraw(result_ok and nil or tostring(result_err))
  end

  return result_ok, result_err, meta
end

return M
