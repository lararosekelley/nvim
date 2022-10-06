local map = require("utils").map

vim.g.vimwiki_create_link = 0
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_listsyms = "✗○◐●✓"

vim.g.vimwiki_list = {
  {
    path = "/run/media/tylucaskelley/Storage/Dropbox/Files/notes/",
    syntax = "markdown",
    ext = ".md",
  }
}

vim.api.nvim_create_user_command("Notes", "VimwikiIndex", { bang = true })
vim.api.nvim_create_user_command("Diary", "VimwikiDiaryIndex", { bang = true })

vim.cmd [[
  augroup VimWikiSettings
    autocmd!

    " use 120 textwidth for vimwiki files for easy reformatting
    autocmd FileType vimwiki setlocal textwidth=120

    " 4 space indent
    autocmd FileType vimwiki setlocal shiftwidth=4 softtabstop=4

    " automatically update links when reading diary index page
    autocmd BufRead,BufNewFile diary.md VimwikiDiaryGenerateLinks

    " keep my original keymappings for some commands
    autocmd FileType vimwiki nnoremap <buffer> <Tab> /
    autocmd FileType vimwiki nnoremap <buffer> <CR> :noh<CR><CR>

    " vimwiki commands
    autocmd FileType vimwiki nnoremap <buffer> wh :VimwikiIndex<CR>
    autocmd FileType vimwiki nnoremap <buffer> wd :VimwikiDiaryIndex<CR>
    autocmd FileType vimwiki nnoremap <buffer> wf :VimwikiFollowLink<CR>
    autocmd FileType vimwiki nnoremap <buffer> ws :VimwikiVSplitLink<CR>

    " customize syntax regions
    autocmd FileType vimwiki syntax region VimwikiBlockquote start=/^\s*>/ end="$"

    " change hightlight groups
    autocmd FileType vimwiki highlight link VimwikiBlockquote mkdBlockquote
  augroup end
]]


map("n", "<leader>n", ":VimwikiIndex<CR>")
