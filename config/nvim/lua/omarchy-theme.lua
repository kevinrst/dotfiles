-- omarchy-theme.lua
-- Applies an NvChad base46 theme live, without restarting Neovim.
-- Used by the omarchy theme-set hook (omarchy/hooks/theme-set.d/nvchad-theme
-- in the dotfiles): the hook persists the theme to chadrc.lua, then calls
-- this in every running nvim server. Same two calls NvChad's own
-- `:Telescope themes` picker uses to preview themes instantly.

local M = {}

--- Apply a base46 theme immediately (compiles cache + loads highlights).
---@param theme string base46 theme name, e.g. "tokyonight"
---@return boolean ok
function M.apply(theme)
  if type(theme) ~= "string" or theme == "" then
    return false
  end

  local has_nvconfig, nvconfig = pcall(require, "nvconfig")
  if not has_nvconfig then
    return false
  end

  local has_base46, base46 = pcall(require, "base46")
  if not has_base46 then
    return false
  end

  nvconfig.base46.theme = theme
  base46.load_all_highlights()
  return true
end

return M
