# Alenia UI Integrator

Official Godot 4 plugin developed by **Alenia Studios**. This tool is designed to automate the integration of UI assets, specifically optimized for Alenia UI Packs.

## Key Features
- **Smart 9-Slice Deployment**: Automatically parses file names (e.g., _32px) to set margins correctly.
- **Automatic Anchoring**: Sets UI elements to "Full Rect" and handles container wrapping instantly.
- **Pixel-Perfect Filtering**: Forces `TEXTURE_FILTER_NEAREST` to preserve the integrity of your pixel art.
- **Interactive Component Detection**: Automatically creates Buttons or NinePatchRects based on file metadata.
- **Massive Fix Tool**: Includes a "Fix Selected Nodes" utility to repair anchors and filters in existing scenes.

## Installation
1. Download or clone this repository.
2. Copy the `addons/alenia_ui_integrator` folder into your Godot project's `res://addons/` directory.
3. Go to **Project > Project Settings > Plugins** and enable "Alenia UI Integrator".
4. Access the new "Alenia UI" dock in your editor.

## Compatibility
- **Engine**: Godot 4.x.
- **Assets**: Optimized for Alenia Studios UI Packs available on itch.io.

## License
All code is provided under **CC BY 4.0 (Attribution Required)**.
You are free to use, share, and adapt this tool as long as appropriate credit is given to Alenia Studios.

---
Developed by KXLT for Alenia Studios.
[Visit our Store on itch.io](https://alenia-studios.itch.io/)
