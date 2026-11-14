local VARIABLE_DELIMITER_OPEN = '{{'
local VARIABLE_DELIMITER_CLOSE = '}}'

---@class Builder
---@field buffer table<string>
---@field map table<string, integer>
local Builder = {}
function Builder.new()
    return setmetatable({ buffer = {}, map = {} }, { __index = Builder })
end

---@param text string
---@return integer
function Builder:add(text)
    table.insert(self.buffer, text)
    table.insert(self.buffer, "")
    return #self.buffer
end

---@param name string
---@param index integer
function Builder:addMap(name, index)
    self.map[name] = index
end

---@param variables table<string, string>
function Builder:apply(variables)
    for name, pos in pairs(self.map) do
        local val = variables[name] or ""
        self.buffer[pos] = val
    end

    return table.concat(self.buffer, "")
end

-- ---@param value string
-- ---@return Builder
-- function Builder.searchForVariables(value)
--     value = value or ""
--
--     local builder = Builder.new()
--
--     local searchingForVariableClose = false
--     local variableIndex = 0
--
--     local index = 1
--     local current = 1
--
--     -- local variablesCount = 0
--     -- while true do
--     --     if current > #value then
--     --         if index < current then
--     --             local fullValue = value:sub(index, current - 1)
--     --             builder:add(fullValue)
--     --         end
--     --         break
--     --     end
--     --
--     --     if searchingForVariableClose then
--     --         if value:sub(current, current + 1) == VARIABLE_DELIMITER_CLOSE then
--     --             searchingForVariableClose = false
--     --             variablesCount = variablesCount + 1
--     --
--     --             local variableName = value:sub(index, current - 1)
--     --             builder:addMap(variableName, variableIndex)
--     --
--     --             index = current + 2
--     --             current = current + 1
--     --         end
--     --     else
--     --         if value:sub(current, current + 1) == VARIABLE_DELIMITER_OPEN then
--     --             searchingForVariableClose = true
--     --             local beforeVariable = value:sub(index, current - 1)
--     --             variableIndex = builder:add(beforeVariable)
--     --
--     --             index = current + 2
--     --             current = current + 1
--     --         end
--     --     end
--     --
--     --     current = current + 1
--     -- end
--
--     -- assert(not searchingForVariableClose)
--     return builder
-- end

return Builder
