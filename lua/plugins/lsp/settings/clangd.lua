return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    -- ask GCC for its system headers, since most projects here build with it
    "--query-driver=/usr/bin/g++,/usr/bin/c++,/usr/bin/gcc",
  },
}
