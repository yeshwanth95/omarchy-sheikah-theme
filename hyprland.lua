-- Sheikah — window borders and their halo.
--
-- Hyprland has an inner glow (decoration:glow, CHyprInnerGlowDecoration) but no
-- outer one, and this halo sits outside the border. The tool for that is
-- decoration:shadow, left at its default [0, 0] offset: with no offset the
-- shadow does not fall to one side but spreads evenly on all four edges, which
-- reads as light coming off the border. That is the native path rather than a
-- workaround -- shadow is a first-class decoration and [0, 0] is its documented
-- default. The halo carries the same 45° sweep as the border itself, so the
-- light and the edge emitting it stay in register around the whole perimeter.
--
-- Colors are literal here because a theme-supplied hyprland.lua is not a .tpl
-- and gets no {{ }} substitution. They mirror colors.toml — if the palette
-- changes, change both.

-- #258af5 accent/blue (the tapestry's bright crosses) -> #bddcff bright_cyan
local active_border_color = { colors = { "rgba(258af5ff)", "rgba(bddcffff)" }, angle = 45 }
local inactive_border_color = "rgba(0b346caa)"

-- The halo runs a rung hotter than the border and ends near white, so the
-- falloff goes charged edge -> blue bloom -> navy. That chromatic step is what
-- makes it read as emitted light rather than a thicker blue outline.
local active_shadow_color = { colors = { "rgba(258af5ff)", "rgba(e9f1fcff)" }, angle = 45 }
-- Unfocused windows keep a trace of it, well under the focused one.
local inactive_shadow_color = "rgba(15508f66)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      -- Spread in px. Held under gaps_out (10) so neighbouring windows'
      -- halos never touch.
      range = 8,
      -- Falloff exponent. Higher is tighter and more concentrated at the
      -- edge; 3 is the Hyprland default.
      render_power = 4,
      color = active_shadow_color,
      color_inactive = inactive_shadow_color,
    },
  },
})
