
function _G.get_place ()
  --[[
  -- Doesn't work for https stuff
  local response = send_request({
    method = "GET",
    uri = "https://ifconfig.me/",
    headers = {
      ["accept"] = "text/plain",
    },
    body = ""
  })
  local place = response.body
  ]]

  -- Ideally, this would be a raw request, like above
  local cmd = "curl ifconfig.me"
  local file = assert(io.popen(cmd, 'r'))
  local place = assert(file:read('*a'))
  file:close()

  log.info("Current place: " .. place)

  return place
end