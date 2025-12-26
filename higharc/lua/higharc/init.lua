-- higharc.nvim - Neovim integration for the Higharc CLI
local M = {}

local config = require("higharc.config")

---Setup higharc.nvim
---@param opts HigharcConfig|nil
function M.setup(opts)
  config.setup(opts)

  -- Create user commands
  M._create_commands()

  -- Register cmp source
  require("higharc.cmp").setup()
end

---Create vim user commands
function M._create_commands()
  local cmd = vim.api.nvim_create_user_command

  -- Main picker
  cmd("Higharc", function(args)
    if args.args == "" then
      require("higharc.picker").pick()
    else
      require("higharc.terminal").run(args.args)
    end
  end, {
    nargs = "?",
    desc = "Open Higharc command picker or run a command",
    complete = function(arglead, cmdline, _)
      -- Use cached completions for speed, fallback to CLI
      local picker = require("higharc.picker")
      local cache = picker.get_subcommand_cache()
      local commands = picker.get_commands()

      local parts = vim.split(cmdline, "%s+")
      table.remove(parts, 1) -- remove "Higharc"

      -- Build lookup key (most specific)
      local lookup_key = ""
      local lookup_parts = {}
      if #parts > 0 then
        if cmdline:match("%s$") then
          lookup_parts = parts
          lookup_key = table.concat(parts, " ")
        else
          if #parts > 1 then
            lookup_parts = { unpack(parts, 1, #parts - 1) }
            lookup_key = table.concat(lookup_parts, " ")
          else
            lookup_parts = {}
            lookup_key = ""
          end
        end
      end

      -- Try cache first
      local cached = cache[lookup_key]
      local completions = {}
      local seen = {}

      if cached then
        for _, comp in ipairs(cached) do
          if not seen[comp] and (arglead == "" or comp:match("^" .. vim.pesc(arglead))) then
            seen[comp] = true
            table.insert(completions, comp)
          end
        end
      elseif #lookup_parts > 0 then
        -- Cache miss - fetch from CLI and cache it
        local root = config.get_project_root()
        local cmd = config.get_cmd()
        local args = vim.split(cmd, "%s+")
        table.insert(args, "--get-yargs-completions")
        table.insert(args, "higharc")
        for _, p in ipairs(lookup_parts) do
          table.insert(args, p)
        end
        table.insert(args, "")

        local result = vim.system(args, { cwd = root, text = true, timeout = 10000 }):wait()
        if result.code == 0 and result.stdout then
          local fetched = {}
          for line in result.stdout:gmatch("[^\r\n]+") do
            if line ~= "" and not line:match("^:") then
              table.insert(fetched, line)
              if not seen[line] and (arglead == "" or line:match("^" .. vim.pesc(arglead))) then
                seen[line] = true
                table.insert(completions, line)
              end
            end
          end
          -- Cache for next time
          cache[lookup_key] = fetched
        end
      elseif #parts == 0 and commands then
        -- Top level - show commands
        for _, cmd in ipairs(commands) do
          if arglead == "" or cmd.full:match("^" .. vim.pesc(arglead)) then
            table.insert(completions, cmd.full)
          end
        end
      end

      return completions
    end,
  })

  -- Test commands
  cmd("HigharcTest", function(args)
    if args.args == "" then
      require("higharc.test").run_current()
    else
      require("higharc.test").run(args.args)
    end
  end, {
    nargs = "?",
    desc = "Run tests (current file if no pattern given)",
  })

  cmd("HigharcTestWatch", function()
    require("higharc.test").watch_current()
  end, {
    desc = "Run tests in watch mode for current file",
  })

  cmd("HigharcTestPick", function()
    require("higharc.test").pick()
  end, {
    desc = "Pick a test command to run",
  })

  -- Utility commands
  cmd("HigharcRefresh", function()
    require("higharc.picker").clear_cache()
    vim.notify("Higharc command cache cleared", vim.log.levels.INFO)
  end, {
    desc = "Refresh higharc command cache",
  })
end

-- Expose submodules
M.picker = require("higharc.picker")
M.terminal = require("higharc.terminal")
M.test = require("higharc.test")
M.config = config

return M
