-- ayu-dark colorscheme based on Kitty terminal palette
vim.cmd("highlight clear")
vim.g.colors_name = "ayu-dark"

local c = {
  bg = "#0a0e14",
  fg = "#b3b1ad",
  accent = "#e6b450",
  red = "#ea6c73",
  red_bright = "#f07178",
  green = "#91b362",
  green_bright = "#c2d94c",
  yellow = "#f9af4f",
  yellow_bright = "#ffb454",
  blue = "#53bdfa",
  blue_bright = "#59c2ff",
  cyan = "#90e1c6",
  cyan_bright = "#95e6cb",
  magenta = "#d2a6ff",
  black = "#01060e",
  gray = "#626a73",
  gray_bright = "#b3b1ad",
  white = "#c7c7c7",
  white_bright = "#f8f8f2",
  line = "#11151c",
  gutter = "#3d424d",
  visual = "#1a1f29",
  panel = "#0d1016",
  comment = "#626a73",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.panel })
hl("FloatBorder", { fg = c.gutter, bg = c.panel })
hl("CursorLine", { bg = c.line })
hl("CursorLineNr", { fg = c.accent, bold = true })
hl("LineNr", { fg = c.gutter })
hl("SignColumn", { bg = c.bg })
hl("ColorColumn", { bg = c.line })
hl("Visual", { bg = c.visual })
hl("Search", { fg = c.bg, bg = c.accent })
hl("IncSearch", { fg = c.bg, bg = c.yellow_bright })
hl("MatchParen", { fg = c.accent, bold = true })
hl("Pmenu", { fg = c.fg, bg = c.panel })
hl("PmenuSel", { fg = c.bg, bg = c.blue_bright })
hl("PmenuThumb", { bg = c.gutter })
hl("PmenuSbar", { bg = c.panel })
hl("WinSeparator", { fg = c.gutter })
hl("StatusLine", { fg = c.fg, bg = c.panel })
hl("StatusLineNC", { fg = c.gutter, bg = c.panel })
hl("TabLine", { fg = c.gutter, bg = c.panel })
hl("TabLineFill", { bg = c.panel })
hl("TabLineSel", { fg = c.fg, bg = c.bg })
hl("Folded", { fg = c.comment, bg = c.line })
hl("FoldColumn", { fg = c.gutter })
hl("NonText", { fg = c.gutter })
hl("SpecialKey", { fg = c.gutter })
hl("Directory", { fg = c.blue_bright })
hl("Title", { fg = c.accent, bold = true })
hl("ErrorMsg", { fg = c.red })
hl("WarningMsg", { fg = c.yellow })
hl("ModeMsg", { fg = c.fg, bold = true })
hl("MoreMsg", { fg = c.green })
hl("Question", { fg = c.green })
hl("WildMenu", { fg = c.bg, bg = c.accent })

-- Syntax
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.magenta })
hl("String", { fg = c.green_bright })
hl("Character", { fg = c.green_bright })
hl("Number", { fg = c.yellow_bright })
hl("Boolean", { fg = c.yellow_bright })
hl("Float", { fg = c.yellow_bright })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.yellow_bright })
hl("Statement", { fg = c.yellow_bright })
hl("Conditional", { fg = c.yellow_bright })
hl("Repeat", { fg = c.yellow_bright })
hl("Label", { fg = c.yellow_bright })
hl("Operator", { fg = c.fg })
hl("Keyword", { fg = c.yellow_bright })
hl("Exception", { fg = c.yellow_bright })
hl("PreProc", { fg = c.yellow_bright })
hl("Include", { fg = c.yellow_bright })
hl("Define", { fg = c.yellow_bright })
hl("Macro", { fg = c.yellow_bright })
hl("Type", { fg = c.blue_bright })
hl("StorageClass", { fg = c.yellow_bright })
hl("Structure", { fg = c.blue_bright })
hl("Typedef", { fg = c.blue_bright })
hl("Special", { fg = c.accent })
hl("SpecialChar", { fg = c.accent })
hl("Tag", { fg = c.blue_bright })
hl("Delimiter", { fg = c.fg })
hl("SpecialComment", { fg = c.comment })
hl("Debug", { fg = c.red })
hl("Underlined", { fg = c.blue_bright, underline = true })
hl("Ignore", { fg = c.gutter })
hl("Error", { fg = c.red })
hl("Todo", { fg = c.accent, bold = true })

-- Treesitter
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.red })
hl("@variable.parameter", { fg = c.fg })
hl("@constant", { fg = c.magenta })
hl("@constant.builtin", { fg = c.magenta })
hl("@module", { fg = c.blue_bright })
hl("@string", { fg = c.green_bright })
hl("@string.escape", { fg = c.accent })
hl("@string.regex", { fg = c.accent })
hl("@character", { fg = c.green_bright })
hl("@number", { fg = c.yellow_bright })
hl("@boolean", { fg = c.yellow_bright })
hl("@type", { fg = c.blue_bright })
hl("@type.builtin", { fg = c.blue_bright, italic = true })
hl("@attribute", { fg = c.accent })
hl("@property", { fg = c.blue_bright })
hl("@function", { fg = c.yellow_bright })
hl("@function.builtin", { fg = c.yellow_bright })
hl("@function.call", { fg = c.yellow_bright })
hl("@function.method", { fg = c.yellow_bright })
hl("@constructor", { fg = c.accent })
hl("@keyword", { fg = c.yellow_bright })
hl("@keyword.function", { fg = c.yellow_bright })
hl("@keyword.return", { fg = c.yellow_bright })
hl("@keyword.operator", { fg = c.yellow_bright })
hl("@keyword.import", { fg = c.yellow_bright })
hl("@operator", { fg = c.fg })
hl("@punctuation", { fg = c.fg })
hl("@punctuation.bracket", { fg = c.fg })
hl("@punctuation.delimiter", { fg = c.fg })
hl("@comment", { fg = c.comment, italic = true })
hl("@tag", { fg = c.blue_bright })
hl("@tag.attribute", { fg = c.yellow_bright })
hl("@tag.delimiter", { fg = c.fg })
hl("@markup.heading", { fg = c.accent, bold = true })
hl("@markup.link", { fg = c.blue_bright, underline = true })
hl("@markup.link.url", { fg = c.cyan, underline = true })
hl("@markup.raw", { fg = c.green_bright })
hl("@markup.list", { fg = c.accent })

-- Diagnostics
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.cyan, undercurl = true })

-- Git signs
hl("GitSignAdd", { fg = c.green })
hl("GitSignChange", { fg = c.yellow })
hl("GitSignDelete", { fg = c.red })

-- Diff
hl("DiffAdd", { bg = "#1a2a1a" })
hl("DiffChange", { bg = "#1a1f2a" })
hl("DiffDelete", { fg = c.red, bg = "#2a1a1a" })
hl("DiffText", { bg = "#2a2f3a" })

-- Misc
hl("Added", { fg = c.green })
hl("Changed", { fg = c.yellow })
hl("Removed", { fg = c.red })
