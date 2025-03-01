return {
  "snacks.nvim",
  opts = {
    image = {
      enabled = true,
      doc = {
        inline = false, -- Disable inline images since they're causing errors
        float = true, -- Use floating windows for images instead
      },
    },
  },
}
