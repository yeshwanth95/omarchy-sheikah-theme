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

### The active menu row (half ships, half is a manual edit)

The row under the cursor in the Omarchy menu gets the Slate's active frame: it
sinks to the tapestry ground colour, takes the bright edge of a focused window,
grows a bracket in each corner, and throws a halo the way the window borders do.
`assets/menu_item_active.svg` is the design reference the numbers came from.

**The colours ship with the theme and need no edit at all.** `shell.menu.toml`
restates the whole `[menu]` section — a theme override replaces its section
rather than merging into it, so every key has to be present, not just the ones
that change — and turns on tokens Omarchy already understands:

```toml
selected-background       = "#00060c"   # was a translucent wash of the foreground
selected-background-alpha = 0.9
selected-border           = "#bddcff"
selected-border-alpha     = 1.0         # Omarchy's default is 0.0, i.e. invisible
selected-border-width     = 1
```

That alone gives you the fill and the outline. The brackets and the halo need a
patched menu, and are driven by four keys Omarchy has no tokens for:

```toml
selected-corners          = 8           # bracket leg in px; 0 or absent = off
selected-glow             = "#258af5"
selected-glow-alpha       = 0.70
selected-glow-blur        = 14
row-border                = "#15508f"   # the dim outline on every other row
row-border-alpha          = 0.55
row-border-width          = 1
```

`Color.parseShell` keeps any key it does not recognise, so these ride along in
`Color.shellValues` with no Omarchy change — the same trick `shell.lock.toml`
uses for its frame. Colours must be quoted: an unquoted `#` starts a comment.

The patch itself goes in your menu plugin's `Menu.qml`, same caveat as the logo
above — the menu belongs to whichever plugin owns it, so an installer has no
business rewriting your `shell.json`. In the row delegate:

- a `Loader` at `z: -1` holding a hidden `Rectangle` plus a `MultiEffect` with
  `shadowEnabled` and **both offsets at zero**, so the shadow spreads evenly
  instead of falling to one side — the same reasoning as the window halo in
  `hyprland.lua`;
- a `Repeater` of four `Shape` items for the brackets, one path rotated
  `0/90/270/180` about its own centre;
- `borderSpec` on idle rows pointed at `row-border` instead of `Border.none()`.

Three things are easy to get wrong, all of them found the hard way:

- **Do not use `layer.effect` for the glow.** `MultiEffect` only honours
  `autoPaddingEnabled` when it has its own `source`; as a layer effect it
  inherits the row's geometry and clips the halo away entirely. Routing the row
  through a layer also costs you the border — it drops from `#bddcff` to about
  76% brightness.
- **`ListView` overwrites a delegate's `x`.** Anchor with
  `anchors.horizontalCenter` instead, or the row slides to the clip edge and the
  halo is sheared off left and right.
- The list is widened into the card's padding by the glow's reach and given back
  to each row, so the visible row keeps its width. Row *heights* stay untouched,
  which is what keeps the fold maths honest.

**Restart the shell afterwards** — `omarchy restart shell`. As with the logo, the
menu plugin is `keepLoaded` and a hot reload will not rebuild it.

Theme-conditional like everything else: a theme that sets none of those keys
renders the stock flat row, the `Loader`s never instantiate, and switching away
reverts with no restart.

### The menu opening and closing (same split again)

Stock, the menu appears and disappears on a single frame. That is not an
oversight in Hyprland's config so much as a gap: `omarchy-menu` sits in a
`no_anim` layer rule whose comment says panels are expected to carry their own
QML transition, and the menu is the one surface in that list that never got one.
So the compositor stays out of the way and nothing takes its place.

Two more keys in the same `[menu]` section give the card a grow from its own
centre on the way in and a shrink back to it on the way out, with the scrim
fading on the same clock:

```toml
open-duration             = 140   # ms, both directions. 0 or absent = off
open-scale                = 0.87  # scale the card starts from. 1.0 = fade only
```

140ms / `OutCubic` is the shell's own house timing — the identical literal sits
in `PopupCard.qml`, `KeyboardPanel.qml`, `PanelSlider.qml` and
`WidgetButton.qml` — so the menu moves like every other Quickshell surface.
0.87 is Hyprland's own grow distance for a window opening (`popin 87%` in
`looknfeel.lua`), which puts the menu and the windows under it on the same
footing.

The QML half is small, and all of it leans on one fact: the menu's layer surface
is already full-screen with the card laid out inside it, so scaling the card
needs no surface resize at all, and `BorderSurface` is a `Rectangle`, so its
`transformOrigin` is `Item.Center` already. In the `PanelWindow`:

- a `shown` property for the *logical* open (`opened && rowsLoaded`), and
  `visible: shown || card.opacity > 0` so the surface outlives the logical close
  by the length of the shrink — the `PopupCard.qml` idiom;
- `opacity` and `scale` on the card, each with a `Behavior` gated on whether the
  theme asked for an animation at all;
- **keyboard focus and the input mask follow `shown`, never `visible`.** An
  exclusive grab held through the shrink locks the keyboard out for its
  duration, and an app the menu just launched comes up behind a surface that
  still owns input. `KeyboardPanel.qml` has this lesson written in a comment;
  it is the one thing here you cannot skip.

Two subtler ones, both only visible once the card outlives the close:

- **Unfreeze the card's top line on the way in, not on the way out.** Reopening
  mid-shrink never lowers `visible`, so a reset hung off that is skipped and the
  new menu inherits the last one's frozen top.
- **Do not clear the filter in the close paths.** It used to be invisible
  because the surface vanished on the same frame; now the rows and the prompt
  line are seen reverting to the unfiltered menu on the way out. Clear it when
  the surface actually unmaps — both open paths clear it themselves anyway.

Theme-conditional like the rest: with neither key set, the `Behavior`s stay
disabled, `visible` collapses back to `shown`, and the surface unmaps on the
same frame it always did.

### The lock screen frame (opt-in)

`assets/sheikah_frame.png` can be drawn over the lock screen's blurred
wallpaper, under the passphrase field. It is **opt-in**, because unlike
everything else here a broken lock screen keeps you out of your own machine:

```bash
./install.sh --with-lock
omarchy restart shell          # the lock service is keepLoaded; edits need this
omarchy-shell lock preview     # SAFE: renders the real view, takes no session lock
```

`lock preview` is the way to check it. It builds the same `LockView` in an
ordinary layer-shell window without engaging `WlSessionLock`, so it cannot lock
you out. Click anywhere to dismiss. Preview lands on one monitor only; the real
lock draws per-screen.

Omarchy's lock screen cannot be themed from a theme file — none of the `[lock]`
keys accept an image — so this clones `omarchy.lock` into
`~/.config/omarchy/plugins/sheikah.lock/` and patches it. Two things keep that
honest:

- The clone is **built from your own machine's lock plugin at install time**,
  never from a copy frozen into this repo. `Service.qml` carries the PAM flow,
  and shipping a stale one would be a broken login on any Omarchy but the
  version this theme was written against.

  Every edit is anchored on a line checked to occur **exactly once** first, and
  an edit whose anchor has moved simply does not happen. Most are inserts.
  Two are whole-line replacements — a sharper tool than an insert, so each is
  gated on its own rather than sharing a gate with anything else. **No edit
  touches the authentication code.** The stages are independent: if the view
  has been reshaped upstream you get the stock lock screen; if only
  `Service.qml` has moved you still get the frame and the fade-in, and lose
  only the unlock fade.
- `install/lock-frame/UPSTREAM` records the hashes it was built from, so after
  an Omarchy upgrade you can check for drift:

  ```bash
  (cd /usr/share/omarchy/shell/plugins/lock && \
     sha256sum -c ~/.config/omarchy/plugins/sheikah.lock/UPSTREAM)
  ```

  If it fails, re-run `./install.sh --with-lock` to rebuild against the new one.

`sheikah_frame_art.svg` is the editable master; `sheikah_frame.png` is what the
lock actually loads. The SVG is 4.25 MB (99.8% of it one embedded 3840x2160
raster) and takes 0.72s to rasterize, against 0.064s for the baked PNG. Rebuild
it after editing the master:

```bash
rsvg-convert -w 4102 -h 2382 assets/sheikah_frame_art.svg \
  | magick png:- -alpha on -fuzz 15% -trim +repage \
      -resize '3840x2160!' assets/sheikah_frame.png
```

The trim is load-bearing, not tidying. The artwork is inset **twice**: the SVG's
`2051x1191` canvas holds the frame in an inner `1920x1080` rect at `(71,57)` —
padding that exists as bleed room for the two Gaussian-blur glow filters — and
the embedded raster has a further ~8.5% padding of its own, top and bottom.
Render the canvas as-is and those add up to a visible margin on all four sides
instead of a bezel. `-fuzz 15%` trims the faint outer glow but keeps the solid
stone, landing the art flush (measured: L 0.0% / T 1.0% / R 0.5% / B 0.7%).

`-resize '3840x2160!'` — the `!` forces the non-uniform scale, since the trimmed
art is not 16:9 and the lock stretches it to the screen anyway.

**It is theme-conditional.** The frame is opted into by one key in
`shell.lock.toml`:

```toml
frame = "assets/sheikah_frame.png"
```

### Fading the lock in and out

Stock, the lock screen appears and disappears on a single frame. Nothing is
going to do that for you: Hyprland has **no animation leaf for a session lock**
at all, and an `ext-session-lock` surface is not a layer surface, so no
`layer_rule` can reach it either. One more key turns on a fade in both
directions:

```toml
fade-duration = 140   # ms. 0 or absent = the stock instant lock
```

It fades against nothing, which is the trick that makes it cheap:
`WlSessionLockSurface` is set to `Color.background` and the view's own first
child is an opaque `Rectangle` of that same colour, so putting `opacity` on the
view lifts the wallpaper, the frame and the passphrase field up out of a
backdrop that never itself changes. A true cross-fade with your desktop is not
on offer — `ext-session-lock-v1` requires the compositor to stop presenting
client content, so Hyprland composites the lock against its own backdrop and
there is nothing behind to dissolve into.

**The reveal waits for the wallpaper.** The blurred background takes about
400ms to decode here, which lands squarely mid-fade; without the wait the view
finishes rising on a bare colour and the wallpaper then appears underneath it,
which reads as a fault rather than a fade. The wait is capped at 700ms so a
slow or missing image costs a fixed delay instead of holding the passphrase
field back for good.

**The way out is the awkward direction.** `WlSessionLock` destroys its surfaces
the moment `locked` goes false, and the surface's own `visible` is read-only —
there is no `visible: open || opacity > 0` escape the way there is for an
ordinary panel. So the release has to be held back, and the only place to do
that is `Service.qml`, which is why that file stopped being verbatim:

```diff
-    sessionLock.locked = false
+    root.releaseSessionLock()
```

That line sits strictly downstream of the authentication decision —
`finishUnlock()` is reached only from the two PAM success paths, both behind
`PamResult.Success`. It changes *when* a lock is released, never *whether* it
should be. Three things keep it safe:

- **A `Timer` is the authority, never the animation.** It fires and releases
  whether or not anything on screen finished moving, so a stalled fade cannot
  keep you locked out.
- **The duration is capped at 1000ms** in the QML. On this side it is time the
  session stays locked after a correct password, so a theme does not get to
  make it unbounded.
- **A lock arriving inside the fade window wins outright.** Without that guard
  the pending timer would fire against a session that had meanwhile been locked
  again and drop the lock you just asked for. It is guarded twice: the new lock
  cancels the timer, and the timer re-checks before releasing.

If it ever does go wrong, `misc:allow_session_lock_restore` is on by default in
Omarchy, so `omarchy restart shell` from a TTY recovers a stuck lock.

While you are in there, the installer also carries one unrelated local
preference: the lock screen's blank delay, upstream's 5s, is set to 10s. It is
gated separately like everything else, so an upstream retune just leaves it
alone.

Omarchy splices `shell.*.toml` sections into the staged `shell.toml` verbatim
and keeps keys it does not recognise, so any theme can set this and themes that
do not set it get the stock lock screen. Switching themes swaps the frame in and
out live, with no shell restart.

To undo: `./install.sh --uninstall` disables the clone (which restores
`omarchy.lock`) before removing it. That order matters — deleting first would
strand you with no lock plugin at all.

### Runes instead of bullets

Omarchy masks the password with `●`, set explicitly in `LockView.qml`. The
theme ships its own font, and in **Sheikah Complete the period is a rune**, so
pointing the mask at `.` fills the field with runes as you type. Three keys:

```toml
password-char       = "."
password-char-font  = "assets/sheikah-complete.ttf"
password-char-scale = 0.85
```

The font is **loaded out of the theme directory, not installed on your
machine** — nothing lands in `~/.local/share/fonts`, nothing needs `fc-cache`,
and switching themes leaves no residue. That is also the only arrangement that
can tell whether the font actually arrived: `FontLoader` reports a status,
where a named system family is silently substituted when it is missing. It
matters more here than anywhere else in the theme, because **a `.` drawn in the
ordinary UI font is a mask you can barely see.** If the font does not load, the
field falls back to the stock bullet.

`password-char-scale` exists because the rune fills its whole em square, where
a bullet's ink is only about 42% of its box — at 1.0 the field reads very
dense. 0.85 keeps it bold with some air.

The patch is **inserts only**, like the frame. The lines that would otherwise
need editing are not all uniquely anchorable — `font.family: Style.font.family`
occurs three times at the same indent — but the two objects involved carry ids,
so a handful of `Binding` elements retarget them from the block the installer
already splices. `when: false` makes Qt restore the original bindings, which is
what makes this vanish cleanly under any other theme.

One thing to know if you swap the font file: it is resolved against the staged
theme directory, whose path is byte-identical for every theme, so **editing the
`.ttf` in place needs `omarchy restart shell`** before the new glyphs appear.
Changing the *keys* needs only a theme apply, like everything else.

## About that allowlist

Re-enabling Lua re-opens a hole Omarchy closed on purpose, so the hook only
does it for themes named in `~/.config/omarchy/theme-extras.allow`, one per
line. Running `install.sh` is the act of vouching for this theme. Every other
installed theme stays denied exactly as Omarchy intended — installing a second
themed repo does not get its Lua executed just because this hook exists.

If you would rather read before you trust, `hyprland.lua` is the whole of it:
two border colors, two halo colors, and a `decoration.shadow` block. You can simply implement this manually in your copy of the theme if you're not comfortable running scripts.

## How the glow works

Hyprland has an inner glow (`decoration:glow`) but no outer one, and this halo
sits outside the border. The tool for that is `decoration:shadow`, left at its
default `[0, 0]` offset: with no offset the shadow does not fall to one side but
spreads evenly on all four edges, which reads as light coming off the border.
That is the native path, not a workaround — `shadow` is a first-class decoration
and `[0, 0]` is its documented default. The halo
runs a rung hotter than the border and ends near white, so the falloff goes
charged edge → blue bloom → navy. That chromatic step is what makes it read as
emitted light rather than a thicker blue outline.

`range` is held at 8, under Omarchy's default `gaps_out` of 10, so neighbouring
windows' halos never touch.

## What's in here

```
colors.toml        the palette — single source of truth for everything generated
hyprland.lua       border gradient + halo (needs install.sh on a cloned install)
assets/            quest_marker.svg (workspace indicator), triforce.svg (menu logo),
                   sheikah_frame_art.svg (master) + sheikah_frame.png (lock frame),
                   menu_item_active.svg (design reference for the active menu row),
                   sheikah-complete.ttf (the lock screen's password-mask runes)
screensaver.txt    the Sheikah eye, in braille
about.txt          the same, for the about window
shell.bar.toml     the bar, as the Slate's bezel
shell.lock.toml    the lock screen
shell.menu.toml    the menu, and the active row's frame
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
