# 🧹 Ubuntu Debloater

A modular and customizable shell script toolkit to debloat Ubuntu and its derivatives (Kubuntu, Xubuntu, etc.). This project helps you remove unnecessary packages, disable unwanted services, and clean up your system for better performance and minimalism.

---

## 🚀 Features

- Detects Ubuntu flavor automatically
- Removes pre-installed bloatware by flavor
- Disables unnecessary background services
- Cleans up residual files and caches
- Modular scripts for easy customization
- Logs every action and backs up package lists

---

## 📦 Supported Flavors

- Ubuntu (GNOME)
- Kubuntu (KDE)
- Xubuntu (XFCE)
- [More coming soon...]

---

## 🛠️ Usage

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ubuntu-debloater.git
cd ubuntu-debloater
```

### 2. Make the Script Executable

```bash
chmod +x debloat.sh
```

### 3. Run the script (as root)

```bash
sudo ./debloat.sh
```

⚠️ Always review the package and service lists before running. You can customize them in the config/ and services/ directories.

---

### 🧩 Customization

Add or remove packages in `config/custom-packages.txt`

Modify service lists in `services/`

Extend or modify behavior in `scripts/` and `utils/`

---

### 📝 Logs & Backups

Logs are saved in logs/ with timestamps

A backup of installed packages is saved in backups/ before any removal

---

### 🧪 Testing

Run test scripts from the tests/ directory to validate functionality:

```bash
bash tests/test-detect-flavor.sh
```

### 📜 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

### 🤝 Contributing

Pull requests are welcome! If you have suggestions for improvements or want to support more Ubuntu flavors, feel free to fork and contribute.

---

### 🙏 Acknowledgments

Inspired by the minimalist Linux philosophy and the desire for a faster, cleaner Ubuntu experience.

“Simplicity is the ultimate sophistication.” – Leonardo da Vinci
