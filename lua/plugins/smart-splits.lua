return {
  "mrjones2014/smart-splits.nvim",
  --  build = "./kitty/install-kittens.bash",
  event = "VeryLazy",
  -- stylua: ignore
  config = function()
    require("smart-splits").setup()
  end,
}
