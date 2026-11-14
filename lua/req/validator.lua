local M = {}

---@param versionLine string
---@return boolean
function M.validateHTTPVersion(versionLine)
    if string.find(versionLine, "^HTTP/%d%.%d$") == nil then
        return false
    end
    return true
end

---@param url string
---@return boolean
function M.validateUrl(url)
    if vim.startswith(url, "http://") then
        return true
    end

    if vim.startswith(url, "https://") then
        return true
    end

    if vim.startswith(url, "file://") then
        return true
    end

    return false
end

return M
