function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function string.expand (s, ...)
  local args = {...}
  args = #args == 1 and type(args[1]) == "table" and args[1] or args
  -- return true if there was an expansion
  local function DoExpand (iscode)
  local was = false
  local mask = iscode and "()%$(%b{})" or "()%$([%a%d_]*)"
  local drepl = iscode and "\\$" or "\\\\$"
  s = s:gsub(mask, function (pos, code)
    if s:sub(pos-1, pos-1) == "\\" then
      return "$"..code
    else
    was = true
    local v, err
    if iscode then
      code = code:sub(2, -2)
    else
      local n = tonumber(code)
      if n then v = args[n] end
    end
    if not v then
      v, err = load("return tostring("..code..")") if not v then error(err) end
      v = v()
    end
    if v == nil then v = "" end
      v = tostring(v):gsub("%$", drepl)
      return v
    end
  end)
  if not (iscode or was) then s = s:gsub("\\%$", "$") end
  return was
  end

  repeat DoExpand(true); until not DoExpand(false)
  return s
end

_G.expand = string.expand

function string:capitalize()
  return self:sub(1,1):upper() .. self:sub(2)
end