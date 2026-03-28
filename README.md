
# 🛡️ ArchZero-Cyber (v9.1)

<p align="center">
  <img src="https://img.shields.io/badge/OS-Arch_Linux-blue?logo=archlinux&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-Shell-4EAA25?logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/Infra-Docker-2496ED?logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Security-BlackArch-red?logo=archlinux&logoColor=white" />
  <img src="https://img.shields.io/badge/Tools-Git-F05032?logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
</p>

Welcome to **ArchZero-Cyber**, a professional-grade "zero-touch" provisioning system designed to deploy a complete cybersecurity laboratory on Arch Linux. Originally developed for the **CyberChallenge.IT** competition, this script automates the complex setup of tools, environments, and system configurations required for high-level CTFs.

> **⚠️ Disclaimer**: This project is created for **educational and ethical hacking purposes only**. The author is not responsible for any misuse or damage caused by these tools. Always perform security tests on systems you own or have explicit permission to test.

## 🛠️ Environment Setup
This repository is strictly optimized for **Arch Linux**. It is designed to keep development environments synchronized across different machines (VMs or Bare Metal), ensuring consistent performance and tool availability.

> **New to Arch Linux?**
> If you need to install the OS first, check out my **[Arch Installation Guide (INSTALL.md)](INSTALL.md)** for a fast-track VM setup and post-install tips.

---

## 🚀 Quick Start
To transform a fresh Arch installation into a hacking workstation, open your terminal and follow these steps:

**1. Install Git** (required to clone the repository):

```bash
sudo pacman -S --needed git
```

> [!CAUTION]
> **Authentication & Confirmation**: The terminal will prompt you for your `user password` (the one you created during installation).
> Note that characters will remain invisible as you type for security reasons. Afterwards, type `Y` and press Enter to confirm the installation.

**2. Clone the repository and navigate into it**:

```bash
git clone https://github.com/TonyScar47/ArchZero-Cyber.git
cd ArchZero-Cyber
```

**3. (Optional) Customize your tools**:
Before running the deployment, you can edit the script to add or remove specific packages from the ALL_TOOLS array.

```bash
nano setup.sh
```

**4. Execute the setup**:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

---

## ⚙️ Technical Specifications & Automation Logic
This script is a full environment orchestrator featuring professional logic:

### 1. System & Network Optimization
- **Parallel Downloads**: Automatically enables 10 parallel streams in `pacman.conf` for maximum speed.
- **Smart Mirroring**: Uses `Reflector` to fetch the 20 fastest synchronized HTTPS mirrors `globally`. It includes a 20-second connection timeout to ensure reliability even on slower networks.
- **Code Reliability**: Implements professional error handling with `set -euo pipefail` and `trap` logic. In case of failure, a `setup_error.log` file is generated in the current directory; if the setup succeeds, the log is automatically deleted to keep the workspace clean.

### 2. Advanced Repositories & Toolchains
- **BlackArch Integration**: Automatically hooks into the BlackArch repository for access to specialized security tools.
- **AUR Support**: Installs and configures `yay` as an AUR helper for seamless community package management.
- **Exploitation Stack**: Deploys critical tools including `GDB`, `Radare2`, `Burp Suite`, `SQLmap`, `Nmap`, `Wireshark`, and `John the Ripper`.

### 3. Isolated Development Environments
- **Python Venv**: Creates a dedicated Virtual Environment to prevent system-wide dependency conflicts.
- **Pre-loaded Libraries**: Includes `pwntools`, `scapy`, `pycryptodome`, `requests`, `dirsearch`, and `beautifulsoup4`.

### 4. System Administration
- **Services**: Enables and starts the `docker.service` immediately.
- **Permissions**: Automatically adds the user to `docker` and `wireshark` groups for non-root tool execution.

---

## 💡 Troubleshooting & Maintenance

### Connectivity Issues (DNS)
If you experience network issues:
1. `ping -c 4 8.8.8.8`
2. If `google.com` fails, reset your nameserver: `echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf`

### Git & VS Code Synchronization
If you encounter sync issues in VS Code, use these commands to resolve conflicts:
- **`git pull origin main --rebase`**: Fetches remote changes and reapplies your local commits on top, keeping a clean history.
- **`git push origin main`**: Uploads your local work to the remote repository.
- **`git config --global user.name "YourName"`**: Sets your identity for commit attribution.
- **`git config --global user.email "YourEmail@email.com"`**: Sets your email for GitHub contribution tracking.

If you have local conflicts or want to discard local changes and perfectly match the remote repository, use these commands:
- **`git fetch --all`**: Downloads the latest metadata and history from the remote repository (GitHub) without modifying your local files. 
- **`git reset --hard origin/main`**: Forces your local branch to match the remote main branch exactly.

> [!CAUTION]
> This will permanently delete any unsaved local changes or file permissions (like chmod +x) you've made to the repository

### System Services
If Docker or other services are not responding:

`sudo systemctl start docker.service`: Manually starts the Docker engine.

---

## 🚨 Login Failures & Missing User Profile
If the system does not recognize your custom username or you encounter login errors (often due to insufficient disk space during installation), follow these steps to regain access and fix the account:

1. **Emergency Login**: Use **`root`** as the username and enter the password you created during the installation.
2. **Check User Existence**: Run `id your_username` to see if the account exists.
3. **Reset Password**: If the user exists, run `passwd your_username` to set a new password.
4. **Manual Creation**: If the user is missing, create it with:
   
    ```bash
     useradd -m -G wheel -s /bin/bash your_username
     passwd your_username
    ```

> [!CAUTION]
> After running this command, you must type the username again if prompted, then the system will ask you to enter a new password for this user. You will then be asked to repeat the password to confirm it.
> Note: characters will not appear while typing.
    
5. **Fix Permissions**: Ensure your user owns its home directory:

    ```bash
      chown -R your_username:your_username /home/your_username
    ```
    
6. **Logout and Switch User**: To exit the root session and return to the login screen to enter as your new user:

   ```bash
      pkill -u root
    ```

7. **Switch to Root**: If you are logged in with your new user and cannot use `sudo`, enter the Root shell by typing:

   ```bash
   su -
    ```

8. **Edit Sudoers File**: Open the configuration file using the Nano editor:

   ```bash
   EDITOR=nano visudo
    ```
9. **Enable Admin Privileges**:

- Scroll down until you find the line: # %wheel ALL=(ALL:ALL) ALL
- Remove the # symbol at the beginning of the line to "uncomment" it, exactly as shown in the reference image below.
- Save the changes by pressing Ctrl+O, then Enter, and exit with Ctrl+X.

<img width="621" height="265" alt="image" src="https://github.com/user-attachments/assets/ff5fd40b-e5d6-40ef-8937-a975f59a2940" />

10. **Apply and Switch User**: To exit the root session and return to the login screen:

    ```bash
    pkill -u root
    ```

11. **Final Verification**: 
    - Log in with your desired username (e.g., `cici`).
    - Open the terminal and type:

      ```bash
      sudo whoami
      ```
    - If the terminal responds with **`root`**, the configuration was successful, and you now have full administrative privileges.

---

## ⌨️ Useful Terminal Shortcuts (GNU Readline)
- **Ctrl + A / E**: Jump to the start or end of the command line.
- **Ctrl + K / W**: Delete everything after the cursor / delete the previous word.
- **Ctrl + L**: Clear the terminal screen.
- **Ctrl + R**: Search through your command history.

---

## 🛠️ Script setup.sh
If the script is already present on your machine and you want to apply manual updates or new commands:

#### 1. Navigate to the directory:

```bash
cd ArchZero-Cyber
```

#### 2. List directory contents to verify setup.sh is present:

```bash
ls
```

#### 3. Grant execution permissions:

```bash
chmod +x setup.sh
```

#### 4. Run the script:

```bash
sudo ./setup.sh
```

---

## 📜 License & Credits
- Licensed under the **MIT License**.
- Developed with ❤️ by **Tony-ScarFace**.

---

## 📊 Technical Resource Analysis (The Logic)
Below is the technical breakdown justifying the **recommended** hardware specs for this environment:

### 🧠 RAM Allocation
* **Burp Suite Professional/Community**: As a Java-based application, it requires a minimum of **2GB** for active scanning.
* **VS Code & Development**: Electron-based apps like VS Code average around **1GB** of RAM usage.
* **OS & Docker Stack**: A base Arch install with active Docker containers typically consumes **1.5GB to 2GB**.
* **Conclusion**: **4GB** is the functional threshold, while **8GB** is recommended for professional multitasking.

### ⚡ CPU Performance
* **Parallel Tasks**: The script utilizes **10 parallel downloads** and AUR compilation, which are CPU-intensive.
* **Security Scanning**: Tools like `nmap` and `sqlmap` use multi-threading for faster discovery.
* **Optimization**: Allocating **4 or more cores** (even numbers) allows the VM hypervisor to manage resource cycles efficiently.

### 💾 Storage Requirements
* **Core System & Tools**: The base installation plus the security stack takes up approximately **15-20GB**.
* **Wordlists (Seclists)**: Includes `seclists`, which significantly increases disk usage for password auditing.
* **Docker & Logs**: A **20GB - 40GB** disk is the professional standard to accommodate Docker images and logs.

---

### Happy Hacking! 💀

---
