function _G.send_request (request)

  if type(request) == "string" then
    request = {uri = request}
  end

  request.uuid = uuid.v4()
  events["outgoing_request_about_to_be_sent"]:trigger({ request = request })

  local response = client_request.send(request)
  response.uuid = uuid.v4()
  events["incoming_response_received"]:trigger({ response = response })

  return response
end
