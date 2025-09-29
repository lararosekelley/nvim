rockspec_format = "3.0"
package = "nvim"
version = "1.0-1"
source = {
  url = "git+ssh://git@github.com/lararosekelley/nvim",
}
description = {
  summary = "My Neovim configuration files",
  detailed = [[
    This repository contains my Neovim configuration files, including settings,
    key mappings, and plugins to enhance the Neovim experience. Heavily inspired
    by my previous Emacs configuration, viewable at lararosekelley/emacs.d
  ]],
  homepage = "https://larakelley.com",
  issues_url = "https://github.com/lararosekelley/nvim/issues",
  license = "MIT",
  maintainer = "Lara Kelley <lararosekelley@gmail.com>",
  labels = { "neovim", "configuration", "lua", "vim" },
}
dependencies = {
  "lua >= 5.1, < 5.5",
}
build = {
  type = "builtin",
  modules = {
    ["config.autocmds"] = "lua/config/autocmds.lua",
    ["config.icons"] = "lua/config/icons.lua",
    ["config.keymaps"] = "lua/config/keymaps.lua",
    ["config.lazy"] = "lua/config/lazy.lua",
    ["config.options"] = "lua/config/options.lua",
    ["plugins.ai"] = "lua/plugins/ai.lua",
    ["plugins.coding"] = "lua/plugins/coding.lua",
    ["plugins.colorscheme"] = "lua/plugins/colorscheme.lua",
    ["plugins.completion"] = "lua/plugins/completion.lua",
    ["plugins.dap"] = "lua/plugins/dap.lua",
    ["plugins.dashboard"] = "lua/plugins/dashboard.lua",
    ["plugins.db"] = "lua/plugins/db.lua",
    ["plugins.files"] = "lua/plugins/files.lua",
    ["plugins.help"] = "lua/plugins/help.lua",
    ["plugins.lsp.handlers"] = "lua/plugins/lsp/handlers.lua",
    ["plugins.lsp.init"] = "lua/plugins/lsp/init.lua",
    ["plugins.lsp.settings.lua_ls"] = "lua/plugins/lsp/settings/lua_ls.lua",
    ["plugins.lsp.settings.pyright"] = "lua/plugins/lsp/settings/pyright.lua",
    ["plugins.lsp.settings.ts_ls"] = "lua/plugins/lsp/settings/ts_ls.lua",
    ["plugins.notifications"] = "lua/plugins/notifications.lua",
    ["plugins.search"] = "lua/plugins/search.lua",
    ["plugins.sessions"] = "lua/plugins/sessions.lua",
    ["plugins.terminal"] = "lua/plugins/terminal.lua",
    ["plugins.treesitter"] = "lua/plugins/treesitter.lua",
    ["plugins.ui"] = "lua/plugins/ui.lua",
    ["plugins.wiki"] = "lua/plugins/wiki.lua",
    ["utils.init"] = "lua/utils/init.lua",
    ["utils.lsp"] = "lua/utils/lsp.lua",
  },
}
test_dependencies = {
  "busted >= 2.2.0",
  "luassert >= 1.9.0",
  "luafilesystem >= 1.7.0",
  "nlua",
}
