local function read_file(path)
    local file = io.open(path, "r")

    if not file then
        return nil
    end

    local file_content = file:read("*all")
    file:close()
    return file_content
end

-- Basically io.lines except it doesn't fails if the file doesn't exist
local function read_lines(path, ...)
    local file = io.open(path, "r")

    -- Returning an empty function makes the for loop do nothing
    if not file then
        return function () end
    end

    local _f, s, var = file:lines(...)

    -- Returns the parameters as they are but if the first parameter is nil closes the file
    -- (lua loops stop after the first result of the iterator function is nil)
    local function bridge (var1, ...)
        if var1 == nil then
            file:close()
        end
        return var1, ...
    end

    -- A wrapper that closes the file when the iterator ends
    local function f (s, var)
        return bridge(_f(s, var))
    end

    return f, s, var
end

local function get_all_files_in(directory)
    local filenames = {}
    local pfile = io.popen('ls -p "'..directory..'"')

    for filename in pfile:lines() do
        if filename:sub(1, 1) ~= "/" then
            table.insert(filenames, filename)
        end
    end

    pfile:close()
    return filenames
end

local function directory_list(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile
    if directory == "" then
        pfile = popen('ls -d '..directory..'*/')
    else
        pfile = popen('ls -d '..directory..'/*/')
    end
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local function copy(src_path, dest_path)
    local src_file = assert(io.open(src_path, "r"))
    local dest_file = assert(io.open(dest_path, "w+"))

    dest_file:write(src_file:read("*all"))

    src_file:close()
    dest_file:close()
end

local function append_to_start(file_path, to_append)
    local file = assert(io.open(file_path, "r"))
    local file_content = file:read("*all")
    file:close()

    file = assert(io.open(file_path, "w"))
    file:write(to_append)
    file:write("\n")
    file:write(file_content)

    file:close()
end

return {
    read_file = read_file,
    read_lines = read_lines,
    get_all_files_in = get_all_files_in,
    directory_list = directory_list,
    copy = copy,
    append_to_start = append_to_start
}
