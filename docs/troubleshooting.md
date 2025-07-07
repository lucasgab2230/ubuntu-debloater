# Troubleshooting Guide for Ubuntu Debloater

This document provides solutions to common issues you might encounter while using the Ubuntu Debloater. If you experience problems, please review these tips before seeking further assistance.

## 1. Script Not Running / Permission Denied

**Issue:** When you try to run `debloat.sh` (or `revert_debloat.sh`), you see "Permission denied" or the script doesn't execute.

**Solution:** The script needs executable permissions.

- **Make it executable:**
  ```bash
  chmod +x debloat.sh
  # Also for the revert script if needed:
  chmod +x scripts/revert_debloat.sh
  ```
- **Ensure you are in the correct directory:** Navigate to the `debloater` directory before running `./debloat.sh`.

## 2. "APT package manager not found" Error

**Issue:** The script exits with an error indicating that `apt` is not found.

**Solution:** This error is highly unlikely on Ubuntu or its derivatives, as `apt` is a core component.

- **Verify your distribution:** Double-check that you are indeed running Ubuntu, Kubuntu, Xubuntu, Lubuntu, or Linux Mint.
- **Check your PATH:** Ensure that `/usr/bin` (where `apt` typically resides) is in your system's PATH. This is usually configured correctly by default.

## 3. "Unsupported distribution" Error

**Issue:** The script cannot detect your specific Linux distribution or indicates it's unsupported.

**Solution:**

- **Check `/etc/os-release`:** The script relies on the `/etc/os-release` file to identify your system. Ensure this file exists and contains valid distribution information.
  ```bash
  cat /etc/os-release
  ```
- **Verify supported distributions:** Confirm that your distribution is one of the officially supported ones (Ubuntu, Kubuntu, Xubuntu, Lubuntu, Linux Mint).
- **Manual Override (Advanced):** If you are on a very similar Ubuntu-based distribution, you might temporarily edit `debloat.sh` to force it to use a specific `.list` file, but this is not recommended without understanding the potential risks.

## 4. "Package list file not found" Error

**Issue:** The script complains that a `.list` file (e.g., `config/ubuntu_bloat.list`) is missing.

**Solution:**

- **Verify file structure:** Ensure that the `config/` directory and all the `.list` files are present in their correct locations, as outlined in the file structure (`linuxtoys/debloater/config/`).
- **Check for typos:** Make sure the file names match exactly (e.g., `ubuntu_bloat.list` not `ubuntu_bloat.txt`).
- **Re-clone the repository:** If files are missing, it's best to re-clone the LinuxToys repository to ensure you have all necessary components.

## 5. "Failed to remove some packages" Error

**Issue:** During the `sudo apt-get purge` step, the script reports that some packages failed to remove.

**Solution:**

- **Read the `apt` output:** The `apt` command itself will provide detailed error messages. Look for lines starting with `E:` or `W:` immediately after the failed removal attempt. Common reasons include:
  - **Package not installed:** The package might not have been installed on your system in the first place. The script tries to filter these out, but some edge cases might occur. This is usually harmless.
  - **Dependencies:** Another installed package might depend on the one you're trying to remove, preventing its removal. `apt` will usually explain this. You might need to remove the dependent package first (with caution!).
  - **Locked files/processes:** Sometimes a package cannot be removed because a file it uses is currently open or a process is running. A system restart might resolve this.
  - **Broken packages:** Your `apt` system might have broken packages. Try:
    ```bash
    sudo apt update --fix-missing
    sudo dpkg --configure -a
    sudo apt install --fix-broken
    ```
- **Review your `.list` file:** Ensure there are no typos in the package names in your `config/*.list` file.

## 6. System Instability or Missing Functionality After Debloating

**Issue:** After running the debloater, your system behaves unexpectedly, or a specific application/feature no longer works.

**Solution:** This is the most critical issue and highlights the importance of backups.

- **Identify the missing component:** Try to determine which specific application or feature is broken. This often points to a package that was removed.
- **Use `revert_debloat.sh` (Experimental):** Run the `scripts/revert_debloat.sh` script. This will attempt to reinstall a predefined list of commonly removed packages.
  ```bash
  cd linuxtoys/debloater
  sudo ./scripts/revert_debloat.sh
  ```
  - **Note:** This script is experimental and might not restore everything.
- **Manually reinstall packages:** If you know which package is missing, you can try to reinstall it manually:
  ```bash
  sudo apt install <package-name>
  ```
  - For example, if your image viewer is gone: `sudo apt install ristretto` (for Xubuntu) or `sudo apt install gwenview` (for Kubuntu).
- **Restore from backup/snapshot:** If the issues are severe and the above steps don't help, restoring your system from a pre-debloat backup or VM snapshot is the safest and most reliable solution.

## 7. "Do you want to proceed?" prompt is skipped or not shown

**Issue:** The script runs without asking for user confirmation.

**Solution:**

- **Check for `--assume-yes` or `-y`:** Ensure you are not accidentally passing `--assume-yes` or `-y` to the `debloat.sh` script itself. The script uses `--assume-yes` internally for `apt` _after_ you confirm, but it should always ask you first.
- **Script modification:** If you or someone else modified `debloat.sh`, the confirmation prompt might have been accidentally removed or bypassed. Compare your `debloat.sh` with the original version.

If you encounter an issue not covered here, or if the solutions provided don't resolve your problem, please consider opening an issue on the [LinuxToys GitHub repository](https://github.com/psygreg/linuxtoys) with detailed information about your system and the problem.
