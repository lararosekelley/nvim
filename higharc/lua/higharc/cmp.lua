-- higharc.nvim cmp source
local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_keyword_pattern = function()
  -- Match words and flags (starting with -)
  return [[\-\?\k\+]]
end

source.get_trigger_characters = function()
  return { " ", "-" }
end

source.is_available = function()
  -- Always available - the source will return empty if no completions
  return true
end

source.complete = function(self, request, callback)
  local picker = require("higharc.picker")
  local cache = picker.get_subcommand_cache()

  -- Get the line content before cursor
  local line = request.context.cursor_before_line
  local parts = vim.split(line, "%s+", { trimempty = true })

  local items = {}

  -- Try multiple lookup strategies
  local lookup_keys = {}

  if #parts > 0 then
    if line:match("%s$") then
      -- Space at end, look up the full path
      table.insert(lookup_keys, table.concat(parts, " "))
    else
      -- Typing a word, look up without the last part
      if #parts > 1 then
        local prefix_parts = { unpack(parts, 1, #parts - 1) }
        table.insert(lookup_keys, table.concat(prefix_parts, " "))
      end
    end
    -- Also try just the first part (top-level command)
    table.insert(lookup_keys, parts[1])
  end

  -- Collect completions from all matching keys
  local seen = {}
  local completions = {}

  for _, key in ipairs(lookup_keys) do
    local cached = cache[key]
    if cached then
      for _, comp in ipairs(cached) do
        if not seen[comp] then
          seen[comp] = true
          table.insert(completions, comp)
        end
      end
    end
  end

  -- If no parts yet, show top-level commands
  if #completions == 0 and #parts == 0 then
    local commands = picker.get_commands()
    for _, cmd in ipairs(commands or {}) do
      if not seen[cmd.full] then
        seen[cmd.full] = true
        table.insert(completions, cmd.full)
      end
    end
  end

  -- Convert to cmp items
  local cmp = require("cmp")
  for _, comp in ipairs(completions) do
    local is_flag = comp:match("^%-")
    table.insert(items, {
      label = comp,
      kind = is_flag and cmp.lsp.CompletionItemKind.Property or cmp.lsp.CompletionItemKind.Function,
      detail = is_flag and "flag" or "command",
      sortText = is_flag and "z" .. comp or "a" .. comp, -- Commands before flags
    })
  end

  callback({ items = items })
end

-- Register the source
local function setup()
  local ok, cmp = pcall(require, "cmp")
  if not ok then
    return
  end
  cmp.register_source("higharc", source.new())
end

return {
  source = source,
  setup = setup,
}
