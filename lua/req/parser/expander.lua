local M = {}

---@param input string
---@param variables table<string, string>
function M.expand_all(input, variables)
    return input:gsub("{{%s*(.-)%s*}}", function (match)
        assert(#match > 0)

        local value = variables[match] or ""

        -- TODO: create diagnostics

        return value
    end)
end

return M
