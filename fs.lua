local function read_file(path)
    local file = io.open(path, "r")

    if not file then
        return nil
    end

    local file_content = file:read("*all")
    file:close()
    return file_content
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
    get_all_files_in = get_all_files_in,
    directory_list = directory_list,
    copy = copy,
    append_to_start = append_to_start
}
