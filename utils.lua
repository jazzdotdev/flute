local function table_contains(tab, val)
    for k, v in pairs(tab) do
        if v == val then return true end
    end
    return false
end

return{
    table_contains = table_contains
}