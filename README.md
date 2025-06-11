# My Hyprland Config

This is my personal Hyprland configuration, based on [SolDoesTech's hypr4](https://github.com/SolDoesTech/hypr4).

I’ve removed unnecessary parts, simplified the structure, and fitted the setup to my needs.

## 🧰 Install Guide

After running your `archinstall` setup, follow these steps:

1. Clone this repository:

    ```bash
    git clone https://github.com/FrozenAssassine/Hyprland-Configurator
    cd Hyprland-Configurator
    ```

2. Make the install script executable:

    ```bash
    chmod +x install.sh
    ```

3. Run the installer:

    ```bash
    ./install.sh
    ```

This will copy the necessary config files into your `.config` directory and set up Hyprland with your customized configuration.

## 🛠️ Getting Started

To start editing and using the config:

1. Open the `.config` folder in VS Code:

```bash
cd ~/.config
code .
```

2. Navigate to the `hypr` folder and open `hyprland.conf`.

## 🎛️ Configuration Notes

### 🖥️ Monitors

Set up your monitor layout as needed. A helpful guide is linked inside the config files.

### ⌨️ Input

In the `input` section, you can set your preferred keyboard layout.  
For example, mine is set to:

```ini
kb_layout = de
```

Change it to whatever layout you use.

## 🖼️ Wallpaper

Open hyprpaper.conf to change your wallpaper.
Note: You must specify a wallpaper for each screen manually.
