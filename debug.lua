local uuid_saved = 0

function generate_uuid()
    uuid_saved = uuid.v4()
    print("[DEBUG] UUID generated: " .. uuid_saved)
end

local function uuid_return()
    return uuid_saved
end

local function print_req_info(req)
    local host = "0.0.0.0"
    if req.host then
        host = req.host
    end

    local message = "Host: " .. host .. "\n" .. req.req_line .. "\n\nHTTP headers:\n"

    for k, v in pairs(req.headers) do
        message = message .. k .. ": " .. v .. "\n"
    end

    message = message .. "\nRequest body:\n" .. req.body_raw

    print(message)
end

local function print_req_info_return(req)
    local host = "0.0.0.0"
    if req.host then
        host = req.host
    end

    local message = "Host: " .. host .. "\nMethod: " .. req.req_line:split( " " )[1] .. "\nURL: " .. req.req_line:split( " " )[2] .. "\nHTTP Version: " .. req.req_line:split( " " )[3] .. "\n\nHTTP headers:\n"

    for k, v in pairs(req.headers) do
        message = message .. "\t" .. k .. ": " .. v .. "\n"
    end

    message = message .. "\nRequest body:\n" .. req.body_raw

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
    print_req_info = print_req_info,
    print_req_info_return = print_req_info_return,
    print_res_info_return = print_res_info_return,
    generate_uuid = generate_uuid,
    uuid_return = uuid_return
}
