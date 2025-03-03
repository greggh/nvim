local filetypes = {
  "markdown",
}

if vim.g.ai then
  table.insert(filetypes, "Avante")
end

return {
  "OXY2DEV/markview.nvim",
  ft = filetypes,
  opts = {
    preview = {
      filetypes = filetypes,
      ignore_buftypes = {},
    },
    theme = {
      -- HTML styles applied to the markdown preview
      styles = [[
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, Roboto, 'Helvetica Neue', sans-serif;
          margin: 0 auto;
          padding: 2em;
          max-width: 860px;
          line-height: 1.6;
          font-size: 18px;
          color: #333;
          background-color: #f9f9f9;
        }
        h1, h2, h3, h4, h5, h6 {
          color: #333;
          line-height: 1.2;
          margin-top: 2em;
          margin-bottom: 0.5em;
        }
        img {
          max-width: 100%;
          height: auto;
        }
        pre {
          padding: 1em;
          background-color: #f0f0f0;
          border-radius: 5px;
          overflow-x: auto;
        }
        code {
          background-color: #f0f0f0;
          padding: 0.2em 0.4em;
          border-radius: 3px;
          font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
        }
        blockquote {
          padding-left: 1em;
          border-left: 4px solid #ddd;
          margin-left: 0;
          color: #555;
        }
        table {
          border-collapse: collapse;
          width: 100%;
          margin: 1em 0;
        }
        table, th, td {
          border: 1px solid #ddd;
        }
        th, td {
          padding: 12px;
          text-align: left;
        }
        th {
          background-color: #f2f2f2;
        }
        tr:nth-child(even) {
          background-color: #f9f9f9;
        }
        a {
          color: #0366d6;
          text-decoration: none;
        }
        a:hover {
          text-decoration: underline;
        }
        hr {
          border: 0;
          height: 1px;
          background-color: #ddd;
          margin: 2em 0;
        }
        ul, ol {
          padding-left: 2em;
        }
        p {
          margin-top: 0;
          margin-bottom: 1em;
        }
      ]],
    },
  },
}
