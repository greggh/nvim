return {
  "MagicDuck/grug-far.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    engine = "ripgrep", -- 'astgrep'
    headerMaxWidth = 80,
    transient = true,
    keymaps = {
      replace = { n = "<localleader><enter>" },
      qflist = { n = "<c-q>" },
      syncLocations = { n = "<localleader>s" },
      syncLine = { n = "<localleader>l" },
      close = { n = "q" },
      historyOpen = { n = "<localleader>t" },
      historyAdd = { n = "<localleader>a" },
      refresh = { n = "<localleader>f" },
      openLocation = { n = "<localleader>o" },
      openNextLocation = { n = "<down>" },
      openPrevLocation = { n = "<up>" },
      gotoLocation = { n = "<enter>" },
      pickHistoryEntry = { n = "<enter>" },
      abort = { n = "<localleader>b" },
      help = { n = "g?" },
      toggleShowCommand = { n = "<localleader>p" },
      swapEngine = { n = "<localleader>e" },
      previewLocation = { n = "<localleader>i" },
    },
  },
  config = function(_, opts)
    require("grug-far").setup(opts)
  end,
}
