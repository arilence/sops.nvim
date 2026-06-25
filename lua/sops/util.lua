local M = {}

local SOPS_MARKER_BYTES = {
  ["yaml"] = "mac: ENC[",
  ["yaml.helm-values"] = "mac: ENC[",
  ["json"] = '"mac": "ENC[',
  ["binary"] = '"mac": "ENC[',
}

local SOPS_FILETYPES = {
  ["yaml.helm-values"] = "yaml",
}

M.get_sops_filetype = function(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if string.match(path, "%.bin$") then
    return "binary"
  end

  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  return SOPS_FILETYPES[filetype] or filetype
end

M.is_sops_encrypted = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filetype = M.get_sops_filetype(bufnr)

  local marker = SOPS_MARKER_BYTES[filetype]
  if not marker then
    return false
  end

  for _, line in ipairs(lines) do
    if string.find(line, marker, nil, true) then
      return true
    end
  end
end

return M
