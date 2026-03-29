local M = {}

local function ltex_settings_path()
  return vim.fn.stdpath("config") .. "/lua/plugins/lsp/settings/ltex.lua"
end

local function read_ltex_settings()
  return table.concat(vim.fn.readfile(ltex_settings_path()), "\n")
end

local function update_ltex_clients(word, add)
  for _, client in ipairs(vim.lsp.get_clients({ name = "ltex" })) do
    client.config.settings = client.config.settings or {}
    client.config.settings.ltex = client.config.settings.ltex or {}
    client.config.settings.ltex.dictionary = client.config.settings.ltex.dictionary or {}
    client.config.settings.ltex.dictionary["en-US"] = client.config.settings.ltex.dictionary["en-US"] or {}

    if add then
      if not vim.tbl_contains(client.config.settings.ltex.dictionary["en-US"], word) then
        table.insert(client.config.settings.ltex.dictionary["en-US"], word)
      end
    else
      local kept = {}
      for _, entry in ipairs(client.config.settings.ltex.dictionary["en-US"]) do
        if entry ~= word then
          table.insert(kept, entry)
        end
      end
      client.config.settings.ltex.dictionary["en-US"] = kept
    end

    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end
end

function M.add_word_to_ltex_dictionary()
  local word = vim.fn.expand("<cword>")

  if word == nil or word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  local settings_path = ltex_settings_path()
  local content = read_ltex_settings()

  if content == "" then
    vim.notify("Unable to read settings file", vim.log.levels.ERROR)
    return
  end

  if content:find('"' .. word .. '"', 1, true) then
    vim.notify("Word already exists in dictionary: " .. word, vim.log.levels.INFO)
    return
  end

  local updated, count = content:gsub('(%["en%-US"%]%s*=%s*){%s*}', '%1{ "' .. word .. '" }', 1)

  if count == 0 then
    updated, count = content:gsub('(%["en%-US"%]%s*=%s*{)(.-)(%s*},)', function(prefix, body, suffix)
      local trimmed = body:gsub("^%s+", ""):gsub("%s+$", "")

      if trimmed == "" then
        return prefix .. ' "' .. word .. '" ' .. suffix
      end

      if body:find("\n") then
        return prefix .. body:gsub("%s*$", "") .. '\n        "' .. word .. '",' .. suffix
      end

      return prefix .. body:gsub("%s*$", "") .. ', "' .. word .. '"' .. suffix
    end, 1)
  end

  if count == 0 then
    vim.notify("Could not locate en-US dictionary block", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile(vim.split(updated, "\n", { plain = true }), settings_path)
  pcall(vim.cmd, "silent keepjumps normal! zg")
  update_ltex_clients(word, true)
  vim.notify("Added to dictionary: " .. word, vim.log.levels.INFO)
end

function M.remove_word_from_ltex_dictionary()
  local word = vim.fn.expand("<cword>")

  if word == nil or word == "" then
    vim.notify("No word under cursor", vim.log.levels.WARN)
    return
  end

  local settings_path = ltex_settings_path()
  local content = read_ltex_settings()

  if content == "" then
    vim.notify("Unable to read settings file", vim.log.levels.ERROR)
    return
  end

  local updated, count = content:gsub('(%["en%-US"%]%s*=%s*{)(.-)(}%s*,?)', function(prefix, body, suffix)
    local entries = {}

    for entry in body:gmatch('"(.-)"') do
      table.insert(entries, entry)
    end

    local filtered = {}
    local removed = false

    for _, entry in ipairs(entries) do
      if entry == word then
        removed = true
      else
        table.insert(filtered, entry)
      end
    end

    if not removed then
      return prefix .. body .. suffix
    end

    if #filtered == 0 then
      return prefix .. " " .. suffix
    end

    if body:find("\n", 1, true) then
      local rebuilt = "\n"

      for _, entry in ipairs(filtered) do
        rebuilt = rebuilt .. '        "' .. entry .. '",\n'
      end

      rebuilt = rebuilt .. "      "
      return prefix .. rebuilt .. suffix
    end

    local rebuilt = " "
    for i, entry in ipairs(filtered) do
      rebuilt = rebuilt .. '"' .. entry .. '"'
      if i < #filtered then
        rebuilt = rebuilt .. ", "
      end
    end
    rebuilt = rebuilt .. " "

    return prefix .. rebuilt .. suffix
  end, 1)

  if count == 0 then
    vim.notify("Could not locate en-US dictionary block", vim.log.levels.ERROR)
    return
  end

  if updated == content then
    vim.notify("Word not found in dictionary: " .. word, vim.log.levels.INFO)
  else
    vim.fn.writefile(vim.split(updated, "\n", { plain = true }), settings_path)
  end

  pcall(vim.cmd, "silent! keepjumps normal! zug")
  update_ltex_clients(word, false)
  vim.notify("Removed from dictionary: " .. word, vim.log.levels.INFO)
end

function M.regenerate_custom_spellfile()
  local config_dir = vim.fn.stdpath("config")
  local source = config_dir .. "/spell/en.utf-8.add"
  local target = config_dir .. "/spell/en.utf-8.add.spl"

  if vim.fn.filereadable(source) ~= 1 then
    vim.notify("Missing source spellfile: " .. source, vim.log.levels.ERROR)
    return
  end

  local ok, err = pcall(vim.cmd, "silent mkspell! " .. vim.fn.fnameescape(target) .. " " .. vim.fn.fnameescape(source))
  if not ok then
    vim.notify("Failed to regenerate spellfile: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.notify("Regenerated spellfile: " .. target, vim.log.levels.INFO)
end

return M
