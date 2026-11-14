local Curl = require('req.libs.Curl')
local Response = require('req.libs.Response')
local formatter = require('req.libs.formatter')
local helper = require('req.helper')

---@class req.Result
---@field request Request
---@field response Response
local Result = {}

local M = {}

---@param request Request
---@param callback function
function M.fire(request, callback)
    vim.validate('callback', callback, 'function')

    local curl = Curl.new(request)
    local command = curl:build()

    local on_exit = function (task)
        local output = task.stdout

        local response = Response.from_curl_output(output)
        local lang = helper.lang_from_content_type(response:content_type())

        -- @TODO Create a better module to run formatter
        vim.schedule(function()
            if formatter.has_type(lang) then
                local formatted = formatter.format(lang, response.content)
                if formatted then
                    response.content = formatted
                end
            end

            local result = { request = request, response = response }

            callback(result)
        end)
    end

    -- TODO: dispatch events?
    --       running -> completed 
    --       visual feedback for request in progress
    local job = vim.system(command, { text = true }, on_exit)
end

return M
