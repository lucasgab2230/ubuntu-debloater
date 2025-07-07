# Usage Guide for Ubuntu Debloater

This document provides detailed instructions on how to use the Ubuntu Debloater tool, part of the LinuxToys project. Follow these steps carefully to clean up your Ubuntu or Ubuntu-derived system.

## 1. Prerequisites

Before you begin, ensure you have:

- **A working Ubuntu or Ubuntu-derived system:** This tool is designed for Ubuntu, Kubuntu, Xubuntu, Lubuntu, and Linux Mint.
- **`sudo` privileges:** The script requires root permissions to remove packages.
- **Internet connection:** To download and remove packages using `apt`.
- **Optional but highly recommended:** A recent system backup or a virtual machine snapshot. While the tool is designed to be safe, removing system packages always carries a small risk.

## 2. Getting the Debloater

First, you need to get the `debloater` directory from the LinuxToys project.

1.  **Clone the LinuxToys repository (if you haven't already):**
    ```bash
    git clone [https://github.com/psygreg/linuxtoys.git](https://github.com/psygreg/linuxtoys.git)
    ```
2.  **Navigate into the debloater directory:**
    ```bash
    cd linuxtoys/debloater
    ```

## 3. Making the Script Executable

The main script `debloat.sh` needs to be marked as executable.

```bash
chmod +x debloat.sh
```

## 4. Running the Debloater

Now you can run the debloater script. It will guide you through the process.

1.  **Execute the script with `sudo`:**
    ```bash
    sudo ./debloat.sh
    ```
2.  **Follow the prompts:**
    - The script will first detect your Linux distribution (e.g., Ubuntu, Kubuntu, Linux Mint).
    - It will then read the appropriate package list from the `config/` directory based on your distribution.
    - A list of packages suggested for removal will be displayed on your screen. **Carefully review this list!**
    - You will be asked for confirmation: `Do you want to proceed with removing these packages? (y/N):`
      - Type `y` (or `Y`) and press Enter to proceed with the removal.
      - Type `n` (or `N`) and press Enter, or just press Enter, to cancel the operation.
    - If you confirm, the script will proceed to remove the specified packages using `apt-get purge`.
    - Finally, it will perform cleanup operations (`apt autoremove --purge` and `apt autoclean`) to remove unused dependencies and clear the package cache.

## 5. After Debloating

- **Restart your system:** For the changes to take full effect and to ensure everything is working as expected, it's a good idea to restart your computer after the debloating process is complete.
- **Test your applications:** Open and test the applications you use regularly to ensure no essential functionality was inadvertently removed.

## 6. Customizing Package Lists (Advanced)

The debloater uses `.list` files in the `config/` directory to determine which packages to remove for each distribution.

- **Location:**
  - `config/ubuntu_bloat.list`
  - `config/kubuntu_bloat.list`
  - `config/xubuntu_bloat.list`
  - `config/lubuntu_bloat.list`
  - `config/mint_bloat.list`
  - `config/common_bloat.list` (if used by `debloat.sh`)
- **Editing:** You can open these files with any text editor (e.g., `nano`, `gedit`, `kate`, `mousepad`) and add or remove package names.
  - Each package name should be on a new line.
  - Lines starting with `#` are comments and will be ignored.
- **Caution:** Only remove packages if you are absolutely certain you don't need them. Removing critical system packages can lead to instability or prevent your system from booting. Refer to `docs/package_lists_guide.md` for more details.

## 7. Reverting Changes (Experimental)

If you find that essential functionality has been lost after debloating, you can try to use the experimental `revert_debloat.sh` script.

1.  **Navigate to the scripts directory:**
    ```bash
    cd linuxtoys/debloater/scripts
    ```
2.  **Make the script executable:**
    ```bash
    chmod +x revert_debloat.sh
    ```
3.  **Run the script with `sudo`:**
    ```bash
    sudo ./revert_debloat.sh
    ```
    This script will prompt you for confirmation before attempting to reinstall a predefined list of commonly removed packages.

**Remember:** The `revert_debloat.sh` script is experimental and does not guarantee a full restoration. A system backup is always the safest option.

For further details on package lists and troubleshooting, please check the other documents in the `docs/` directory.
