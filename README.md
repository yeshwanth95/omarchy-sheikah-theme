# Sheikah

An Omarchy theme based on the aesthetic of the Sheikah Slate from *The Legend of Zelda: Breath of
the Wild*.

![Sheikah](preview.png)

Theme colors are sampled from `backgrounds/01-1258416.jpg`, the Sheikah tapestry.

```
background  #00152d      accent/blue  #258af5      cyan     #8fc3ff
foreground  #afc1d5      orange       #ff9e45      red      #ff5c48
```

Focused windows carry a border gradient and a matching halo, at the same 45°
sweep, so the light stays in register with the edge emitting it.

## Backgrounds

Nine wallpapers ship with the theme. Click any for the full-resolution file.

<table>
  <tr>
    <td><a href="backgrounds/01-1258416.jpg"><img src="docs/backgrounds/01-1258416.jpg" width="260" alt="01-1258416.jpg"></a></td>
    <td><a href="backgrounds/02-wallhaven-p8rgpj_3840x2160.png"><img src="docs/backgrounds/02-wallhaven-p8rgpj_3840x2160.jpg" width="260" alt="02-wallhaven-p8rgpj_3840x2160.png"></a></td>
    <td><a href="backgrounds/03-wallhaven-1qrlwv.jpg"><img src="docs/backgrounds/03-wallhaven-1qrlwv.jpg" width="260" alt="03-wallhaven-1qrlwv.jpg"></a></td>
  </tr>
  <tr>
    <td align="center"><sub><b>01</b> &middot; the tapestry &mdash; palette source</sub></td>
    <td align="center"><sub><b>02</b></sub></td>
    <td align="center"><sub><b>03</b></sub></td>
  </tr>
  <tr>
    <td><a href="backgrounds/04-1025644.png"><img src="docs/backgrounds/04-1025644.jpg" width="260" alt="04-1025644.png"></a></td>
    <td><a href="backgrounds/05-wallhaven-gp29gl.jpg"><img src="docs/backgrounds/05-wallhaven-gp29gl.jpg" width="260" alt="05-wallhaven-gp29gl.jpg"></a></td>
    <td><a href="backgrounds/06-wallhaven-dp6kdl.jpg"><img src="docs/backgrounds/06-wallhaven-dp6kdl.jpg" width="260" alt="06-wallhaven-dp6kdl.jpg"></a></td>
  </tr>
  <tr>
    <td align="center"><sub><b>04</b></sub></td>
    <td align="center"><sub><b>05</b></sub></td>
    <td align="center"><sub><b>06</b></sub></td>
  </tr>
  <tr>
    <td><a href="backgrounds/10-wallhaven-k8dyqq.png"><img src="docs/backgrounds/10-wallhaven-k8dyqq.jpg" width="260" alt="10-wallhaven-k8dyqq.png"></a></td>
    <td><a href="backgrounds/11-wallhaven-qro7yq.png"><img src="docs/backgrounds/11-wallhaven-qro7yq.jpg" width="260" alt="11-wallhaven-qro7yq.png"></a></td>
    <td><a href="backgrounds/13-wallhaven-zp9kej.png"><img src="docs/backgrounds/13-wallhaven-zp9kej.jpg" width="260" alt="13-wallhaven-zp9kej.png"></a></td>
  </tr>
  <tr>
    <td align="center"><sub><b>10</b></sub></td>
    <td align="center"><sub><b>11</b></sub></td>
    <td align="center"><sub><b>13</b></sub></td>
  </tr>
</table>

`omarchy bg next` cycles them. `01-1258416.jpg` is the Sheikah tapestry every
color in the theme is sampled from — the palette answers to that image alone.
The rest range wider than the palette does, from near-black slate to the warm
reds of the Ancient murals, on the grounds that a wallpaper is allowed to be a
picture rather than a swatch.

## Install

```bash
omarchy theme install https://github.com/yeshwanth95/omarchy-sheikah-theme.git
```

Then select it from **Omarchy menu → Style → Theme**. That gets you the
palette, the backgrounds and the terminal/editor colors.

### Then optionally run this for enabling the glowing window borders and Sheikah screensaver and branding:

```bash
cd ~/.config/omarchy/themes/sheikah
./install.sh
```

Two parts of the theme cannot switch themselves on, because Omarchy
deliberately will not let a theme installed from a git repo supply them:

- **The border glow.** It needs `hyprland.lua`, and `omarchy-theme-set` strips
  `*.lua` from any theme that arrived as a git clone — Lua is executable code
  running in your Hyprland session, so a stranger's repo does not get to ship
  it. Without this step the borders still get their gradient, but no halo.
- **The screensaver and about art.** `omarchy-screensaver` and
  `omarchy-branding-about` read fixed paths under `~/.config/omarchy/branding/`
  and never consult the active theme, so shipping the art is not enough to
  apply it.

- **The workspace quest marker.** The bar's focused-workspace indicator is a Nerd
  Font glyph, and nothing about it is configurable without QML. Omarchy also
  reserves the whole `omarchy.*` plugin namespace, so the marker ships as a
  stand-in bar widget declaring `clonedFrom: omarchy.workspaces` — Omarchy hands
  it the built-in's slot on enable and hands the slot straight back on disable.
  It decides *at runtime* whether the active theme ships
  `assets/quest_marker.svg`, so under any other theme you get the stock dot.

`install.sh` will enable all three of these. Everything it changes is inside your home directory — no `sudo`, nothing under `/usr`:

| path | what it is |
|---|---|
| `~/.config/omarchy/hooks/theme-set.d/sheikah-theme-extras` | a `theme-set` hook |
| `~/.config/omarchy/theme-extras.allow` | adds `sheikah` to the Lua allowlist |
| `~/.config/omarchy/plugins/sheikah.workspaces/` | the workspace bar widget |

The hook runs on every theme change from then on. It is theme-agnostic: it
leaves themes that ship none of these files alone, and when you switch to a
theme with no ASCII art it restores Omarchy's own rather than stranding the
Sheikah eye.

To undo it:

```bash
./install.sh --uninstall
```

### The menu logo (manual, and only if you want it)

`assets/triforce.svg` can replace the Omarchy mark on the bar's menu button, but
`install.sh` deliberately leaves this one alone. The button belongs to whichever
plugin owns your menu, and there is no supported way to swap a bar slot without
disabling that plugin — `omarchy bar` has no `remove`, and
`omarchy plugin disable` on a menu plugin takes the menu down with it. Rather than
have an installer perform surgery on your `shell.json`, here is the edit.

If your menu is a clone (`~/.config/omarchy/plugins/<you>.menu/`), edit its
`BarWidget.qml`. If you are on the stock `omarchy.menu`, clone it first with
`omarchy plugin clone omarchy.menu`, which never touches `/usr/share`.

Copy the logo block from this theme's own widget — the asset resolution, the
`FileView` on `theme.name`, and the `MultiEffect` tint are all in
`install/plugins/sheikah.workspaces/BarWidget.qml`, pointed at
`assets/triforce.svg` instead. The three load-bearing lines on the button are:

```qml
text: "\ue900"          // keep it: WidgetButton sizes from the hidden label,
                        // so the button stays exactly as wide as before
labelVisible: !root.logoReady
```

plus an `Image` + `MultiEffect { colorization: 1.0; colorizationColor: button.foreground }`
pair centred in the button, which tints the triforce to `bar.text` so it follows
every theme the way the glyph did.

**You must restart the shell afterwards**, not just save: the menu plugin is
`keepLoaded`, and its bar widget is *not* rebuilt by the usual hot reload even
though the log says `Local plugin changed, reloading`. Run `omarchy restart shell`.

Like everything else here, it is theme-conditional — switch to another theme and
the Omarchy mark comes back on its own.

## About that allowlist

Re-enabling Lua re-opens a hole Omarchy closed on purpose, so the hook only
does it for themes named in `~/.config/omarchy/theme-extras.allow`, one per
line. Running `install.sh` is the act of vouching for this theme. Every other
installed theme stays denied exactly as Omarchy intended — installing a second
themed repo does not get its Lua executed just because this hook exists.

If you would rather read before you trust, `hyprland.lua` is the whole of it:
two border colors, two halo colors, and a `decoration.shadow` block. You can simply implement this manually in your copy of the theme if you're not comfortable running scripts.

## How the glow works

Hyprland has no glow primitive. This is `decoration:shadow` with its offset
left at the default `[0, 0]`: instead of falling to one side the shadow spreads
evenly on all four edges, which reads as light coming off the border. The halo
runs a rung hotter than the border and ends near white, so the falloff goes
charged edge → blue bloom → navy. That chromatic step is what makes it read as
emitted light rather than a thicker blue outline.

`range` is held at 8, under Omarchy's default `gaps_out` of 10, so neighbouring
windows' halos never touch.

## What's in here

```
colors.toml        the palette — single source of truth for everything generated
hyprland.lua       border gradient + halo (needs install.sh on a cloned install)
assets/            quest_marker.svg (workspace indicator), triforce.svg (menu logo)
screensaver.txt    the Sheikah eye, in braille
about.txt          the same, for the about window
shell.bar.toml     the bar, as the Slate's bezel
shell.lock.toml    the lock screen
icons.theme        Yaru-prussiangreen-dark
keyboard.rgb       258af5
backgrounds/       01-1258416.jpg is the tapestry everything is sampled from
generator/         draws procedural Sheikah wallpapers — see generator/README.md
docs/              README thumbnails only; nothing here is read at runtime
install.sh         the optional post-install step above
install/           what it installs: the hook and the bar widget
```

`alacritty.toml`, `foot.ini`, `neovim.lua` and `vscode.json` are intentionally
absent: Omarchy generates them from `colors.toml` via its own templates, so
shipping them would only let them drift from the palette.

## Changing the palette

Edit `colors.toml` and re-apply the theme. Two caveats:

- `hyprland.lua` repeats its colors as literal hex, because a theme-supplied
  `.lua` is not a `.tpl` and gets no `{{ }}` substitution. Change both.
- `shell.bar.toml` and `shell.lock.toml` fully replace their sections and are
  applied after templating, so they take literal hex too.

`cyan` is kept a visibly paler rung than `blue` on purpose. `dircolors` paints
directories `01;34` and symlinks `01;36`, and neither foot nor alacritty maps
bold to bright — if those two collapse, `ls` stops distinguishing a symlink
from a directory.
