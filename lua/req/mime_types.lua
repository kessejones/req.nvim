local M = {}

local types = {
    ["plain/text"] = "txt",
    ["application/json"] = "json",
    ["application/xml"] = "xml",
}

function M.type(mime)
    return types[mime]
end

return M
