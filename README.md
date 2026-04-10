# alenia-ui-integrator
Official Godot 4 plugin for Alenia Studios UI Packs. Automates 9-slice setup, anchoring, and pixel-perfect filtering.

# Alenia UI Integrator

[cite_start]Official Godot 4 plugin developed by **Alenia Studios**[cite: 6, 13]. This tool is designed to automate the integration of UI assets, specifically optimized for Alenia UI Packs.

## Key Features
- **Smart 9-Slice Deployment**: Automatically parses file names (e.g., _32px) to set margins correctly.
- **Automatic Anchoring**: Sets UI elements to "Full Rect" and handles container wrapping instantly.
- [cite_start]**Pixel-Perfect Filtering**: Forces `TEXTURE_FILTER_NEAREST` to preserve the integrity of your pixel art[cite: 4, 11].
- **Interactive Component Detection**: Automatically creates Buttons or NinePatchRects based on file metadata.
- [cite_start]**Massive Fix Tool**: Includes a "Fix Selected Nodes" utility to repair anchors and filters in existing scenes[cite: 1, 8].

## Installation
1. Download or clone this repository.
2. [cite_start]Copy the `addons/alenia_ui_integrator` folder into your Godot project's `res://addons/` directory[cite: 7, 14].
3. Go to **Project > Project Settings > Plugins** and enable "Alenia UI Integrator".
4. [cite_start]Access the new "Alenia UI" dock in your editor[cite: 7, 14].

## Compatibility
- [cite_start]**Engine**: Godot 4.x[cite: 5, 12].
- **Assets**: Optimized for Alenia Studios UI Packs available on itch.io.

## License
[cite_start]All code is provided under **CC BY 4.0 (Attribution Required)**[cite: 1, 13].
You are free to use, share, and adapt this tool as long as appropriate credit is given to Alenia Studios.

---
Developed by KXLT for Alenia Studios.
[Visit our Store on itch.io](https://alenia-studios.itch.io/)
