<p align="center">
  <img src="assets/rog-control-center.png" alt="ROG mark" width="112">
</p>

<h1 align="center">G14 Controls</h1>

<p align="center"><strong>ASUS G14 controls that feel native to Omarchy.</strong></p>

<p align="center">
  <code>Live status</code> · <code>Adaptive power</code> · <code>Aura &amp; Slash</code> · <code>GPU / MUX</code>
</p>

Native Omarchy bar controls for ASUS ROG Zephyrus G14 laptops using the
supported `asusctl`/`asusd` stack. It adds a compact Quickshell control panel
and three live bar glyphs for the G14, current power profile, and graphics
state. Click any glyph (or press the configured ROG key) to open the panel.

The bar and panel inherit Omarchy's active theme and font automatically. The
keyboard hue strip remains multicolored because it previews the actual Aura
color range rather than a UI theme color.

## Features

- **Live status glyphs** — focused tooltips show the current or queued graphics
  target, the GPU model selected by that mode, and dGPU runtime state. The
  expansion-card glyph represents Ultimate; the microchip glyph represents
  Integrated and Hybrid, so transient dGPU wakeups do not make the glyph
  oscillate.
- **Focused glyph panels** — select the profile or GPU glyph to open only its
  power or graphics controls, anchored directly below that glyph. The ROG mark
  always opens the complete panel. Compact profile controls use glyphs with
  precise hover labels; the complete panel spells every choice out.
- **Power profiles** — Quiet, Balanced, and Performance controls. Adaptive
  configures ASUS defaults of Balanced on AC power and Quiet on battery; its
  dedicated automatic glyph carries one, two, or three small level marks for
  the current Quiet, Balanced, or Performance target. Choosing a fixed profile
  clears Adaptive by assigning that profile to both AC and battery. Profile
  changes update the bar immediately and replace, rather than stack, their
  desktop notification.
- **Keyboard backlight and Aura** — Off/Low/Medium/High brightness controls,
  a horizontal hue-spectrum selector, and the modes actually exposed by the
  laptop firmware: Static, Breathing, Color Cycle, Rainbow, and Pulse.
- **Slash Lighting** — firmware-provided Slash modes, brightness levels, and
  explicit On/Off controls, shown in Advanced controls when supported.
- **Graphics/MUX controls** — Integrated, Hybrid, and Ultimate/dGPU modes.
  Selecting a mode queues the ASUS firmware change immediately, switches the
  bar/panel to the queued target, and highlights it until the next reboot
  applies it; the running session is left alone. The graphics panel lists the
  exact integrated and discrete adapters reported by `lspci`, so model names
  follow the hardware instead of being hardcoded for one G14 configuration;
  compact labels such as `Radeon 890M` and `RTX 5070 Ti Mobile` keep the panel
  readable.
- **Hardware-key ready** — the README includes the ROG-key binding; the panel
  also supports left-click to open, right-click to cycle profiles, and
  middle-click to refresh.
- **Guided G14 hotkeys** — the separate Setup section can launch `wev` to capture the
  laptop's actual key symbols, then open a confirmation-first setup wizard.
  It offers common G14 defaults, lets users customize or skip each mapping,
  backs up `bindings.lua`, and replaces only its own marked binding block.
- **Complete keyboard navigation** — Arrow keys or `H`/`J`/`K`/`L` move through
  every control, `Enter`/`Space` activates it, and `Esc` closes the panel. On
  the color strip, Left/Right adjusts the hue before `Enter` applies it;
  dropdowns use Up/Down or `J`/`K` and `Enter` to select. `Tab`/`Shift+Tab`
  retains Omarchy's panel-switching behavior.
- **Theme-native UI** — the bar, ROG mark, panel, typography, and controls
  inherit the active Omarchy theme and font automatically. The keyboard hue
  strip stays multicolored because it is a lighting tool, not a theme accent.
- **Keyboard color lock** — opt in to preserve the current supported Aura
  lighting across Omarchy theme changes. The lock creates one user-owned
  `theme-set` hook only while enabled; changing color or effect while locked
  updates the saved lighting, and disabling it removes that hook and state.
  Its compact toggle lives in the separate Setup section.
- **Optional airplane mode** through `rfkill`.

The default panel is deliberately compact: profile, keyboard backlight, and a
visual keyboard-color slider are always visible. **Advanced controls** opens
one short section for Aura effects, Slash controls, and graphics mode.
**Setup** is its own short section for keyboard-color persistence and optional
G14 physical-key configuration; opening one section closes the other so the
panel remains compact.

Graphics mode changes are deliberately manual and require a reboot. The
plugin never switches graphics mode automatically, changes fan curves/TGP/CPU
limits, or requests privileged access. It uses the supported ASUS firmware
endpoints; unsupported model-specific features remain hidden rather than being
emulated.

## Requirements

- Omarchy Quattro and its Quickshell shell
- `asusd` running with `asusctl` and `rog-control-center` installed
- `jq` for status serialization and `pciutils` (`lspci`) for GPU model detection;
  optional `vulkan-tools` (`vulkaninfo`) provides more specific marketing names
  when the PCI database groups multiple GPU variants under one device ID
- ASUS WMI support for the controls exposed by the specific laptop
- `wev` (optional, only for the G14 key-capture action)

The bundled `g14ctl` helper runs with the logged-in user's permissions and
does not request administrative access. The plugin and helper are unsandboxed,
as are Omarchy shell plugins generally; review the code before installing it
on another machine.

## Install

```sh
omarchy plugin add https://github.com/Ayumad/omarchy-g14-controls.git --enable
omarchy bar move ayumad.g14-controls --section right
```

The default refresh interval is 10 seconds. It can be changed in the
widget's settings when supported by the shell.

## ROG-key binding

Add this to `~/.config/hypr/bindings.lua` if the laptop exposes the ROG key as
`XF86Launch1`:

```lua
hl.unbind("XF86Launch1")
o.bind("XF86Launch1", "G14 controls", "omarchy-shell shell toggle ayumad.g14-controls")
```

The widget's right-click cycles profiles and middle-click refreshes its state.
The simple manual binding above does not modify other settings. The optional
guided setup below is the only plugin path that writes Hyprland bindings, and
it asks for final confirmation first.

## Optional guided G14 hotkey setup

In the separate **Setup** section, choose **Capture Keys** to open `wev`, press each
physical special key, and note its symbol. Then choose **Set Up Hotkeys**. The
terminal wizard proposes the common G14 layout, but lets you enter the symbols
you captured or use `-` to skip a mapping:

| Control | Default mapping | Action |
| --- | --- | --- |
| M4 / ROG | `XF86Launch1` | Open G14 Controls |
| Aura | `XF86Launch3` | Next keyboard effect |
| Profile | `XF86Launch4`, `XF86Fn_F5` | Next power profile |
| F6 screenshot | `SUPER + SHIFT + S` | Omarchy screenshot |

Nothing changes until the wizard shows its summary and receives a final `y`.
On confirmation it writes only the block marked
`ayumad.g14-controls hotkeys`, creates a timestamped backup of
`~/.config/hypr/bindings.lua`, installs the small user-local `g14ctl` wrapper
when it is safe to do so, then reloads and validates Hyprland. The screenshot
mapping deliberately overrides that shortcut; skip it if you already use it
for something else. Re-run the wizard to replace only its managed block. Before
removing the plugin, run `g14ctl hotkeys remove` to remove that block and its
user-local wrapper while retaining a timestamped backup.

If keyboard color lock is enabled, turn it off in the panel before removing
the plugin to remove its user-owned theme hook.

## Remove

```sh
omarchy plugin remove ayumad.g14-controls
```

If you created a custom manual Hyprland keybinding, remove that binding
separately. For the guided setup, run `g14ctl hotkeys remove` first.

## License

MIT. See `LICENSE`.
