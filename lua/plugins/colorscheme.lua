-- Override LazyVim's default colorscheme
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
    },
  },
}
