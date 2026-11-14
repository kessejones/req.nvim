local ns = vim.api.nvim_create_namespace('req_result')

local M = {}

---@param buf integer
---@return boolean
function M.is_buffer_visible(buf)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return true
    end
  end

  return false
end

---@param parser vim.treesitter.LanguageTree
---@param query vim.treesitter.Query
---@param buf integer
---@param row_start integer
---@param row_end integer
local function apply_highlights(parser, query, buf, row_start, row_end)
    local lang =  parser:lang()
    local trees = parser:trees()

    for _, tree in pairs(trees) do
        for id, node, metadata in query:iter_captures(tree:root(), buf, row_start, row_end) do
            local name = query.captures[id] or ''
            local sr, sc, er, ec = node:range()
            local priority = tonumber(metadata.priority) or vim.hl.priorities.treesitter

            vim.api.nvim_buf_set_extmark(buf, ns, sr, sc, {
                end_row = er,
                end_col = ec,
                hl_group = "@" .. name .. "." .. lang,
                priority = priority,
                strict = false
            })
        end
    end
end

---@param buf integer
---@param row_start integer?
---@param row_end integer?
function M.hl_clear(buf, row_start, row_end)
    row_start = row_start or 1
    row_end = row_end or -1

    vim.api.nvim_buf_clear_namespace(buf, ns, row_start, row_end)
end

---@param buf integer
---@param hl string
---@param row integer
---@param col integer
---@param end_row integer?
---@param end_col integer?
function M.set_hl(buf, hl, row, col, end_row, end_col)
    vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
        end_col = end_col,
        end_row = end_row,
        hl_group = hl,
    })
end


---@param buf integer
---@param region_lang string?
---@param row_start integer
---@param row_end integer
function M.hl_region_lang(buf, region_lang, row_start, row_end)
    if not region_lang then
        return
    end

    local parser = vim.treesitter.get_parser(buf, region_lang)
    local query = vim.treesitter.query.get(region_lang, 'highlights')

    if parser and query then
        parser:parse(true)
        apply_highlights(parser, query, buf, row_start, row_end)
    end
end

---@param content_type string?
---@return string?
function M.lang_from_content_type(content_type)
    if content_type then
        local matches = string.gmatch(content_type, "(%w+)/(%w+)")
        local _, p2 = matches()
        if p2 then
            return p2
        end
    end
    return nil
end

return M

