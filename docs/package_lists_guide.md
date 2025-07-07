# Guide to Package Lists in Ubuntu Debloater

This document explains how the package lists in the `config/` directory are structured and how you can safely customize them for your specific needs. Understanding these lists is crucial for effectively using the Ubuntu Debloater.

## 1. What are Package Lists?

The Ubuntu Debloater uses simple text files, known as "package lists," to determine which software packages to remove from your system. Each list is tailored to a specific Ubuntu derivative (like Ubuntu, Kubuntu, Xubuntu, Lubuntu, or Linux Mint) to ensure that the debloating process is as safe and effective as possible for that particular environment.

## 2. Location of Package Lists

All package lists are located in the `config/` directory within the `debloater/` tool:

- `config/ubuntu_bloat.list`: For standard Ubuntu installations (usually with GNOME desktop).
- `config/kubuntu_bloat.list`: For Kubuntu installations (with KDE Plasma desktop).
- `config/xubuntu_bloat.list`: For Xubuntu installations (with XFCE desktop).
- `config/lubuntu_bloat.list`: For Lubuntu installations (with LXQt desktop).
- `config/mint_bloat.list`: For Linux Mint installations (e.g., Cinnamon, MATE, XFCE editions).
- `config/common_bloat.list` (Optional): This file can contain packages that are generally considered bloatware across _all_ Ubuntu derivatives. The `debloat.sh` script might be configured to use this in addition to a distribution-specific list.

## 3. Structure of a Package List File

Each package list file is a plain text file with a very simple structure:

- **One package name per line:** Each line should contain the exact name of a package you wish to remove.
- **Comments:** Lines starting with a `#` symbol are treated as comments and are ignored by the script. You can use comments to explain why a package is listed or to temporarily disable its removal.
- **Blank lines:** Empty lines are also ignored.

**Example:**

```
# This is a comment about the following package.
libreoffice-writer
# Another package to remove
thunderbird
gnome-mahjongg # This is a game
```

## 4. How to Customize Package Lists

Customizing these lists allows you to have fine-grained control over what gets removed.

1.  **Open the relevant file:** Use a text editor to open the `.list` file corresponding to your distribution. For example, if you are on Kubuntu, you would open `config/kubuntu_bloat.list`.
    ```bash
    # Example using nano text editor
    nano linuxtoys/debloater/config/kubuntu_bloat.list
    ```
2.  **Add packages:** If you know of a package installed on your system that you consider bloatware and it's not already in the list, simply add its exact package name on a new line.
    - **How to find package names:** You can use `dpkg -l | grep <keyword>` or `apt list --installed | grep <keyword>` to find installed package names.
3.  **Remove packages:** If a package is listed that you _do not_ want to remove (e.g., you use LibreOffice Writer regularly), you have two options:
    - **Delete the line:** Completely remove the line containing the package name.
    - **Comment out the line:** Add a `#` symbol at the beginning of the line. This is safer as it allows you to easily re-enable the package for removal later if you change your mind.
      ```
      #libreoffice-writer  # I want to keep this!
      ```
4.  **Save the file:** After making your changes, save the file.

## 5. Important Warnings and Best Practices

- **Know what you're removing:** Never remove a package if you are unsure of its purpose or its dependencies. Removing critical system components can make your system unstable or even unbootable.
- **Dependencies:** When you remove a package, `apt` might also remove other packages that depend on it. The `debloat.sh` script will show you the list of packages `apt` intends to remove, so pay close attention to this output before confirming.
- **Desktop Environment Packages:** Be extremely cautious when considering removing packages that are core to your desktop environment (e.g., `kubuntu-desktop`, `ubuntu-desktop`, `xfce4`, `lxqt`). Removing these can severely damage your graphical environment. It's usually safer to remove individual applications rather than core desktop meta-packages.
- **Essential System Utilities:** Avoid removing packages like `apt`, `dpkg`, `systemd`, or core kernel components. The debloater script is designed to avoid these, but always be aware.
- **Test in a VM:** If you are making extensive customizations, consider testing your modified package lists in a virtual machine first.
- **Backup:** Always perform a system backup or create a snapshot before running the debloater with custom lists.

By following this guide, you can effectively customize the Ubuntu Debloater to clean your system precisely to your preferences.
