return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, { 'Cargo.toml', 'Cargo.lock', '.git' }))
  end,
  settings = {
    ['rust-analyzer'] = {},
  },
}
