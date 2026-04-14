-- Store the temp buffer globally
local temp_lsp_buf = nil

-- Function to create or reuse a temporary buffer for LSP navigation
local function create_temp_buffer()
  if temp_lsp_buf then
    return temp_lsp_buf
  end
  local buf = vim.api.nvim_create_buf(false, true)
  temp_lsp_buf = buf
  vim.api.nvim_set_current_buf(buf)
  vim.opt_local.bufhidden = "hide"
  vim.opt_local.buflisted = true
  vim.opt_local.swapfile = true
  vim.opt_local.buftype = ""
  vim.opt_local.modifiable = true
  return buf
end

-- Function to load file content into buffer
local function load_file_content(buf, filename, line, col)
  -- If the target is in the current file, just jump to the line
  if filename == vim.api.nvim_buf_get_name(0) then
    vim.api.nvim_win_set_cursor(0, { line, col - 1 })
    return
  end

  -- find if buffer is already open
  local bufnr = vim.fn.bufnr(filename)
  if bufnr ~= -1 then
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { line, col - 1 })
    return
  end

  vim.api.nvim_set_current_buf(buf)
  local content = vim.fn.readfile(filename)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_name(buf, filename)
  vim.api.nvim_win_set_cursor(0, { line, col - 1 })
  vim.opt_local.filetype = vim.filetype.match({ filename = filename })

  -- Enable LSP for the temporary buffer
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    -- Check if the client supports the filetype
    if client.config.filetypes and vim.tbl_contains(client.config.filetypes, vim.bo.filetype) then
      vim.lsp.buf_attach_client(buf, client.id)
    end
  end

  -- -- Add an autocommand to format on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    callback = function()
      vim.notify("Formatting buffer", vim.log.levels.INFO)
      vim.cmd("Format")
    end,
  })

  -- Add an autocommand to handle file write with force
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      vim.opt_local.buflisted = true
      vim.cmd("Format")
    end,
  })

  vim.keymap.set("n", "<leader>w", function()
    vim.opt_local.buflisted = not vim.bo.buflisted
    vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), filename)
  end, { buffer = buf, desc = "Save buffer" })

  -- Add a keybinding to toggle buffer visibility
  vim.keymap.set("n", "<leader>l", function()
    vim.opt_local.buflisted = not vim.bo.buflisted
    vim.notify("Buffer " .. (vim.bo.buflisted and "shown" or "hidden") .. " in buffer list", vim.log.levels.INFO)
  end, { buffer = buf, desc = "Toggle buffer visibility" })

  -- Add a keybinding to close the buffer
  vim.keymap.set("n", "<leader>q", function()
    if vim.bo.modified then
      local choice = vim.fn.confirm("Save changes?", "&Yes\n&No\n&Cancel", 1)
      if choice == 1 then -- Yes
        -- Save first, then delete
        vim.cmd("write!")
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      elseif choice == 3 then -- Cancel
        return
      else                    -- No
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    else
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end, { buffer = buf, desc = "Close buffer" })

  -- Add a keybinding to format the buffer
  vim.keymap.set("n", "<leader>f", function()
    vim.cmd("Format")
    vim.notify("Buffer formatted", vim.log.levels.INFO)
  end, { buffer = buf, desc = "Format buffer" })
end

local function is_test_file(filename)
  return filename:match("_test%.")
      or filename:match("%.test%.")
      or filename:match("%.spec[%./]")
      or filename:match("%.spec$")
      or filename:match("/test_")
      or filename:match("_spec%.")
end

-- Function to handle LSP references in a temporary buffer
-- include_tests: if true show all refs, if false exclude test files
local function lsp_references(include_tests)
  vim.lsp.buf.references({ includeDeclaration = true }, {
    on_list = function(list)
      local items = list.items
      if not include_tests then
        items = vim.tbl_filter(function(item)
          return not is_test_file(item.filename)
        end, items)
      end
      if #items == 0 then
        vim.notify("No references found", vim.log.levels.INFO)
        return
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local title = include_tests and "References (with tests)" or "References"
      pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
          results = items,
          entry_maker = function(entry)
            local display = string.format("%s:%d:%d: %s", entry.filename, entry.lnum, entry.col, entry.text or "")
            return {
              value = entry,
              display = display,
              ordinal = display,
              filename = entry.filename,
              lnum = entry.lnum,
              col = entry.col,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.qflist_previewer({}),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local buf = create_temp_buffer()
            load_file_content(buf, selection.value.filename, selection.value.lnum, selection.value.col)
          end)
          return true
        end,
      }):find()
    end,
  })
end

-- Function to handle LSP implementations in a temporary buffer
local function lsp_implementations()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or "utf-16")
  vim.lsp.buf_request(0, "textDocument/implementation", params, function(_, result)
    if not result or #result == 0 then return end

    -- Create a table of implementations for Telescope
    local implementations = {}
    for _, impl in ipairs(result) do
      local filename = vim.uri_to_fname(impl.uri)
      local line = impl.range.start.line + 1
      local col = impl.range.start.character + 1
      local display = string.format("%s:%d:%d", filename, line, col)
      table.insert(implementations, {
        filename = filename,
        line = line,
        col = col,
        display = display
      })
    end

    -- Use Telescope to show implementations
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
      prompt_title = "Implementations",
      finder = finders.new_table({
        results = implementations,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.display,
            ordinal = entry.display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local buf = create_temp_buffer()
          load_file_content(buf, selection.value.filename, selection.value.line, selection.value.col)
        end)
        return true
      end,
    }):find()
  end)
end

-- Function to handle LSP definition in a temporary buffer
local function lsp_definition()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  local params = vim.lsp.util.make_position_params(0, client and client.offset_encoding or "utf-16")
  vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
    if not result or #result == 0 then return end
    local def = result[1] -- Get the first definition
    local filename = vim.uri_to_fname(def.uri)
    local line = def.range.start.line + 1
    local col = def.range.start.character + 1

    -- If the definition is in the current file, just jump to the line
    if filename == vim.api.nvim_buf_get_name(0) then
      vim.api.nvim_win_set_cursor(0, { line, col - 1 })
      return
    end

    local buf = create_temp_buffer()
    load_file_content(buf, filename, line, col)
  end)
end

return {
  lsp_references = function() lsp_references(false) end,
  lsp_references_with_tests = function() lsp_references(true) end,
  lsp_implementations = lsp_implementations,
  lsp_definition = lsp_definition,
}
