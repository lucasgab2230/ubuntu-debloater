# Ubuntu Debloater for LinuxToys

## Overview

Welcome to the **Ubuntu Debloater**, a powerful and carefully designed tool within the [LinuxToys](https://github.com/psygreg/linuxtoys) project. This utility aims to help users streamline their Ubuntu and Ubuntu-derived systems (such as Kubuntu, Xubuntu, Lubuntu, and Linux Mint) by safely removing unnecessary "bloatware" packages. Our primary goal is to enhance system performance and reduce disk space usage without compromising system stability or core functionality.

## Purpose

Many Linux distributions, including Ubuntu and its derivatives, come pre-installed with a variety of applications and utilities that might not be essential for every user. While these applications can be convenient, they can also consume valuable system resources and disk space. The Ubuntu Debloater provides a systematic way to identify and remove these non-critical packages, giving you a leaner, faster, and more personalized operating system experience.

## Features

- **Distribution-Aware Debloating:** Automatically detects your specific Ubuntu derivative and applies a tailored list of packages for removal, ensuring compatibility and minimizing risks.
- **Safe Removal:** Designed with caution in mind, focusing on non-essential packages to prevent system breakage. It leverages `apt` commands for clean uninstallation.
- **User Confirmation:** Prompts for user confirmation before executing any removal commands, giving you full control over what gets removed.
- **Post-Removal Cleanup:** Includes steps to perform `autoremove` and `autoclean` operations after debloating to ensure all residual files are purged.
- **Reversion Option (Experimental):** An experimental script is provided to help revert some common changes, offering a potential safety net.
- **Configurable Package Lists:** Easy-to-understand configuration files allow advanced users to customize the list of packages to be removed.

## Supported Distributions

The Ubuntu Debloater is designed to work with:

- Ubuntu (Standard GNOME)
- Kubuntu
- Xubuntu
- Lubuntu
- Linux Mint (Cinnamon, MATE, XFCE editions)

## Disclaimer & Warnings

**USE WITH CAUTION!** While this tool is designed to be safe, removing system packages always carries an inherent risk.

- **Backup Your System:** It is **highly recommended** to create a system backup or a snapshot (if using a virtual machine) before running this debloater.
- **Review Package Lists:** Before running the script, we strongly advise you to review the package lists in the `config/` directory to understand exactly what will be removed.
- **No Guarantees:** We cannot guarantee that removing certain packages won't affect specific functionalities you rely on, especially if you have unique software requirements or custom configurations.
- **"Bloatware" is Subjective:** What one user considers "bloatware" another might find essential. The default lists are curated based on common perceptions but may not align with everyone's needs.

## Basic Usage

1. **Navigate to the Debloater Directory:**
   ```bash
   cd /path/to/linuxtoys/debloater
   ```
2. **Make the Script Executable:**
   ```bash
   chmod +x debloat.sh
   ```
3. **Run the Debloater (with sudo):**
   ```bash
   sudo ./debloat.sh
   ```
   The script will detect your distribution, display the packages it intends to remove, and ask for your confirmation.

For more detailed instructions, customization options, and troubleshooting, please refer to the `docs/` directory.

## Contributing

We welcome contributions! If you have suggestions for improving package lists, enhancing the script, or adding support for new derivatives, please feel free to open an issue or submit a pull request on the main [LinuxToys GitHub repository](https://github.com/psygreg/linuxtoys).

## License

This Ubuntu Debloater tool is distributed under the [MIT License](LICENSE).
