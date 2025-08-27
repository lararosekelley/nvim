--- Mapping icons to various constructs within vim. Depends on
--- a nerd font being installed.
---
--- Author: @lararosekelley
--- Last Modified: August 26th, 2025

return {
  icons = {
    misc = {
      dots = "󱗼 ",
      folder = " ",
      time = " ",
    },
    ft = {
      octo = " ",
    },
    mason = {
      package_installed = " ",
      package_pending = " ",
      package_uninstalled = " ",
    },
    dap = {
      Stopped = { " ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = " ",
      BreakpointCondition = " ",
      BreakpointRejected = { " ", "DiagnosticError" },
      LogPoint = "󰦪 ",
    },
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    },
    git = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    kinds = {
      Array = " ",
      Boolean = "󰨙 ",
      Class = " ",
      Codeium = "󰘦 ",
      Color = " ",
      Control = " ",
      Collapsed = "󰘕 ",
      Constant = "󰏿 ",
      Constructor = "󱢛 ",
      Copilot = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = "󰊕 ",
      Interface = " ",
      Key = " ",
      Keyword = " ",
      Method = "󰊕 ",
      Module = "󰕳 ",
      Namespace = "󰦮 ",
      Null = "󰟢 ",
      Number = "󰎠 ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = "󱄽 ",
      String = " ",
      Struct = " ",
      Supermaven = " ",
      TabNine = "󰏚 ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = "󰀫 ",
    },
  },
}
