# 💎 Alenia UI Integrator for Godot 4
*(Official Plugin by Alenia Studios)*

![Godot 4](https://img.shields.io/badge/Godot-4.x-blue?style=flat-square&logo=godot-engine&logoColor=white) 
![License](https://img.shields.io/badge/License-CC%20BY%204.0-darkviolet?style=flat-square) 
[![itch.io](https://img.shields.io/badge/itch.io-Alenia_Studios-FA5C5C?style=flat-square&logo=itch.io&logoColor=white)](https://alenia-studios.itch.io/)

---

## 👋 Introduction

Stop wasting hours setting up UI nodes manually. **Alenia UI Integrator** is a powerful Godot 4 plugin designed to automate the integration of UI assets. It includes **Smart Assembler** logic specifically optimized for **Alenia UI Packs**, turning your loose images into functional, interactive game components instantly.

---

## 🚀 Getting Started

### Installation
1. **Download** or clone this repository.
2. **Copy** the `addons/alenia_ui_integrator` folder into your Godot project's `res://addons/` directory.
3. Go to **Project > Project Settings > Plugins** and click **Enable** next to "Alenia UI Integrator".
4. Access the new **Alenia UI** dock in your editor (usually located next to the Inspector or Scene Tree).

---

## 🛠️ The Naming Guide (Smart Assembler Logic)

To trigger the automatic assembly, your filenames must follow these exact patterns. If recognized, the plugin will group the files, assign correct StyleBoxes/Icons, and apply configuration automatically.

### 1. Buttons (`btn_`)
Create functional `Button` nodes with StyleBoxTexture states already assigned.
> **Format:** `btn_[NAME]_[STATE]_[MARGIN]px.png`
- **NAME:** Group identifier (e.g., `wood`, `cyber`).
- **STATE:** `normal`, `hover`, `pressed`, `disabled`.
- **MARGIN:** (Optional) Integer for 9-slice margins (e.g., `16`).

```text
# ✅ Grouped into one Button named "Metal"
btn_metal_normal_32px.png
btn_metal_hover_32px.png
btn_metal_pressed_32px.png
```

### 2. Sliders (`slider_`)
Assemble complex HSlider nodes with track, fill, and grabber textures.
> **Format:** `slider_[NAME]_[PART]_[MARGIN]px.png`
- **PART:** `track` (background), `progress` (fill), `grabber` (knob).

```text
# ✅ Grouped into one HSlider named "Neon"
slider_neon_track_16px.png
slider_neon_progress_16px.png
slider_neon_grabber.png 
(Note: Grabbers often don't need margins)
```

### 3. Cursors (`cursor_`)
Create non-deformed TextureRect nodes optimized for use as system pointers.
> **Format:** `cursor_[NAME].png`

```text
# ✅ Imported with Nearest filter, not stretched
cursor_pointer_green.png
```

### 4. Panels & Frames (Generic)
Create scalable NinePatchRect nodes for windows, dialogs, and backgrounds.
> **Format:** `panel_[NAME]_[MARGIN]px.png` or `frame_...`

```text
# ✅ NinePatchRect with 32px margins set automatically
panel_scifi_dialog_32px.png
```

---

## ✨ Key Features

- **Smart 9-Slice Deployment:** Instantly sets StyleBox and NinePatch margins by parsing filenames (e.g., `_32px`).
- **Component Auto-Assembly:** Automatically detects and groups files (track, progress, grabber) into a single functional Slider or Button node.
- **Interactive Logic Injection:** Attaches custom scripts (`alenia_button_logic.gd`, `alenia_slider_logic.gd`) and handles audio feedback (hover/click) if sounds are present in the folder.
- **Tipography & Value Display:** Automatically centers text, applies pixel fonts (if found), and adds dynamic value labels to Sliders.
- **Pixel-Perfect Filtering:** Forces `TEXTURE_FILTER_NEAREST` on all imported assets to preserve the fidelity of your pixel art.
- **Project Cursor Hijack:** Dedicated utility to set any cursor asset as the official project mouse pointer with one click.

---

## ⚙️ Compatibility & Requirements

- **Game Engine:** Godot 4.x (Required).
- **Assets:** Highly optimized for Alenia Studios UI Packs available on itch.io.

---

## 📄 License

This code and logic are provided under **Standard Licensing: CC BY 4.0** (Attribution Required). You are free to use, share, and adapt this tool, provided appropriate credit is given to Alenia Studios.

---

## 👨‍💻 Credits & Links

Developed by **KXLT** for **Alenia Studios**.
