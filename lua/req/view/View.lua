local helper = require('req.helper')

---@class req.View
---@field bufnr integer
---@field lines table<string>
---@field request req.Request
---@field response req.Response
---@field content_range req.ContentRange
---@field highlight table
local View = {}

---@param bufnr integer
---@param result req.Result
function View.new(bufnr, result)
    return setmetatable({
        bufnr = bufnr,
        lines = {},
        request = result.request,
        response = result.response,
        content_range = { 0, 0 },
        highlight = {},
    }, { __index = View })
end

---@param input string|table
function View:add_line(input)
    if type(input) == 'string' then
        table.insert(self.lines, input)
    elseif type(input) == 'table' then
        local line = {}

        local sc = 0
        local ec = 0
        local len_before = 0
        for _, i in ipairs(input) do
            if type(i) == 'string' then
                table.insert(line, i)
                ec = ec + #i
                sc = sc + #i
                len_before = #i
            elseif type(i) == 'table' then
                local text = i[2]
                if i.pad_left then
                    text = string.rep(' ', i.pad_left - len_before) .. text
                end

                ec = ec + #text
                table.insert(self.highlight, {
                    hl = i[1],
                    row = #self.lines,
                    col = sc,
                    end_col = ec,
                    end_row = #self.lines,
                })

                sc = sc + #text
                table.insert(line, text)
                len_before = #text
            end
        end

        table.insert(self.lines, table.concat(line, ''))
    else
        vim.notify('req.nvim - invalid type for View add_line', vim.log.levels.WARN)
    end
end

function View:add_separator(separator)
    separator = separator or ''
    self:add_line(separator)
end

function View:update()
    self:add_line({
        { 'Comment', "Method" },
        { 'Keyword', self.request.method, pad_left = 7 }
    })

    self:add_line({
        { 'Comment', "URL" },
        { 'Keyword', self.request.url, pad_left = 7 }
    })

    self:add_line({
        { 'Comment', "Time" },
        { 'Keyword', tostring(self.response.time_total) .. 's', pad_left = 7 }
    })

    self:add_line({
        { 'Comment', "Size" },
        { 'Keyword', tostring(self.response.size_download), pad_left = 7 }
    })

    self:add_line({
        { 'Comment', "Status" },
        { 'Keyword', tostring(self.response.status), pad_left = 7 }
    })

    self:add_separator()
    self:add_separator()

    for name, value in pairs(self.response.headers) do
        self:add_line({
            { 'Comment', name },
            { 'Keyword', value, pad_left = self.response.max_header_name + 2 }
        })
    end

    self:add_separator()

    self.content_range.row_start = #self.lines
    for _, c in ipairs(vim.split(self.response.content, '\n')) do
        self:add_line(c)
    end
    self.content_range.row_end = #self.lines
end

function View:render()
    vim.bo[self.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
    vim.bo[self.bufnr].modifiable = false

    self:highlights()
end

function View:highlights()
    -- TODO: Create highlights for URL, Method and Status code

    for _, h in ipairs(self.highlight) do
        helper.set_hl(self.bufnr, h.hl, h.row, h.col, h.end_row, h.end_col)
    end

    local content_type = self.response:content_type()
    if content_type then
        local lang = helper.lang_from_content_type(content_type)
        -- TODO should I clear all before apply the response
        helper.hl_clear(self.bufnr,
            self.content_range.row_start,
            self.content_range.row_end
        )

        helper.hl_region_lang(
            self.bufnr,
            lang,
            self.content_range.row_start,
            self.content_range.row_end
        )
    end
end

return View
