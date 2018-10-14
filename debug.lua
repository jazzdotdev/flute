local uuid_saved = 0

local log = require "log" 

function generate_uuid()
    uuid_saved = uuid.v4()
    log.trace("UUID generated: " .. uuid_saved)
end

local function uuid_return()
    return uuid_saved
end

local function print_request_info(req)
    local host = "0.0.0.0"
    if request.host then
        host = request.host
    end

    local message = "Host: " .. host .. "\n" .. request.request_line .. "\n\nHTTP headers:\n"

    for k, v in pairs(request.headers) do
        message = message .. k .. ": " .. v .. "\n"
    end

    message = message .. "\nRequest body:\n" .. request.body_raw

    log.debug(message)
end

local function print_request_info_return(req)
    local host = "0.0.0.0"
    if request.host then
        host = request.host
    end

    local message = "Host: " .. host .. "\nMethod: " .. request.request_line:split( " " )[1] .. "\nURL: " .. request.request_line:split( " " )[2] .. "\nHTTP Version: " .. request.request_line:split( " " )[3] .. "\n\nHTTP headers:\n"

    for k, v in pairs(request.headers) do
        message = message .. "\t" .. k .. ": " .. v .. "\n"
    end

    message = message .. "\nRequest body:\n" .. request.body_raw

    return message
end

local function print_res_info_return(res)

    local host = "0.0.0.0"
    if res.host then
        host = res.host
    end

    local message = "Host: " .. host
    message = message .. "\nHTTP Headers:\n"

    for k, v in pairs(res.headers) do
        message = message .. "\t" .. k .. ": " .. v .. "\n"
    end

    message = message .. "\nRequest body:\n" .. res.body

    return message

end

return {
    print_request_info = print_request_info,
    print_request_info_return = print_request_info_return,
    print_res_info_return = print_res_info_return,
    generate_uuid = generate_uuid,
    uuid_return = uuid_return,
}
