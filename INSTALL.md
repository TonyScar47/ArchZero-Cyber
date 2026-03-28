<p align="center">
  <img src="https://img.shields.io/badge/Platform-VirtualBox-89BAE0?logo=virtualbox&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-VMware-607078?logo=vmware&logoColor=white" />
  <img src="https://img.shields.io/badge/Guide-Arch_Linux-blue?logo=archlinux&logoColor=white" />
  <img src="https://img.shields.io/badge/Status-Official_Guide-brightgreen" />
</p>

<h1 align="center">💿 Arch Linux Installation Guide (VM Setup)</h1>

<p align="center">
  <i>This guide provides a fast-track method to set up a fresh Arch Linux environment on a <b>Virtual Machine</b> before running the <b>ArchZero-Cyber</b> script.</i>
</p>

---

## 🌐 1. Download the ISO
1. Visit the official page: **[https://archlinux.org/download/](https://archlinux.org/download/)**.
2. Scroll to **HTTP Direct Downloads**.
3. **Select your Country** from the list to find the nearest mirror.
4. Download the `.iso` file and attach it to your VM.
   
---

## 🏗️ 2. Virtual Machine Preparation

Set up your VM with these specifications for optimal performance:

> *Virtual Machine Name and Operating System:*

* **VM Name**: Choose a unique identifier for your virtual machine.
* **ISO Image**: Select the `.iso` file you downloaded.
* **OS**: Linux.
* **OS Distribution**: ArchLinux.
* **OS Version**: Arch Linux (64-bit).

> *Configure virtual hardware:*

* **CPU**: **4 Cores** (Allocating even numbers improves hypervisor efficiency).
* **RAM**: **4GB to 8GB** (Do not exceed 50% of your host's total RAM).
* **Enable EFI**: **Select** this option for **UEFI support**.

> *Virtual Hard Disk*

* **Disk**: **8GB - 16GB**.

---

## 🛠️ 3. Option A: The Guided Way (`archinstall`)

Once you boot into the ISO, don't touch anything and wait for the automatic boot to complete:

<img width="538" height="177" alt="image" src="https://github.com/user-attachments/assets/c51eff63-bdcd-473d-836f-4bcddf94c795" />

Then type the command below and follow the guided menu:

```bash
archinstall
```

<img width="586" height="287" alt="image" src="https://github.com/user-attachments/assets/88d6e6bb-af90-4644-8866-1737d95a33eb" />

**Recommended Menu Settings:**

> *To navigate the installation menu, use the arrow keys (↑/↓) to move up and down, and press Enter to select or confirm an option.*

  - **Archinstall language**: Select your language.
  > *Note*: This language selection is only for the installation process and does not change the final system language.

  - **Mirrors**: A mirror is a server from which your Arch Linux system downloads its software.
  > *Tip*: Choose a mirror located close to you for faster download speeds.
  
  - **Disk configuration**: Select "Partitioning" -> "Best-effort partition layout" -> "HardDisk" -> Use **Ext4**.
  - **Swap**: Select "Yes (default)" and "zstd (default)".
  - **Bootloader**: Select **GRUB**.
  - **Authentication**: Create a root password, then create a user -> add user and set **"Sudo privileges"** to **Yes** then select "confirm and exit".
  - **Profile**: Select Type -> **Desktop** -> Choose **GNOME** or **KDE Plasma** then select "Back".
  - **Applications**: Select **Audio** -> **pipewire** then select "back".
  - **Network configuration**: Select **Network Manager (default)**.
  - **Timezone**: Select your time zone from the available options.

**Select Install** and then confirm by selecting **Yes**.
> **Note:** After selecting 'Install', a summary of your configuration will be shown. You can save this information if you wish to automate the process in the future.

**At the end of the installation, you will be presented with three choices:**
  - **Chroot**: Enter the newly installed system to perform manual configurations via the terminal.
  - **Reboot**: Restarts the machine to boot into your fresh Arch Linux installation. *(Select this option)*.
  - **Exit/Shutdown**: Closes the installer and returns you to the live ISO command line.

-----

## 🛠️ 3. Option B: The Manual Way (Arch Wiki Standard)

*Reference: [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)*

Once you boot into the ISO, don't touch anything and wait for the automatic boot to complete:

<img width="538" height="177" alt="image" src="https://github.com/user-attachments/assets/c51eff63-bdcd-473d-836f-4bcddf94c795" />

> [!CAUTION]
> **Check Internet Connection**
> An active network connection is required. Please plug in an Ethernet cable or connect via Wi-Fi.

**Step-by-Step Commands:**

```bash
# 1. Partitioning (GPT)
timedatectl set-ntp true
lsblk # Identify your disk (usually /dev/sda or /dev/nvme0n1)
cfdisk /dev/sda # Create a 512MB EFI partition (Type: EFI System) and the rest as Linux Root

# 2. Formatting
mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2

# 3. Mounting
mount /dev/sda2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

# 4. Base Installation
pacstrap /mnt base linux linux-firmware base-devel nano networkmanager sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# 5. System Configuration (Inside Chroot)
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch-cyber" > /etc/hostname
systemctl enable NetworkManager
passwd

# 6. Bootloader (GRUB for UEFI)
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
reboot
```

-----

## ⚠️ 4. CRITICAL: The ISO Ejection

After the script finishes, you MUST log out and log back in (or reboot) for user group permissions (docker, wireshark) to take effect.

**Before rebooting for the first time:**

1.  **Shut down** the Virtual Machine.
2.  Go to VM **Settings** -\> **Storage**.
3.  **Remove/Eject** the Arch ISO from the Optical Drive.
4.  **Restart** the VM.

> [!CAUTION]
> **Stuck in the terminal?**
> If you are back at the installer screen, type `reboot` and immediately go to **Devices** > **Optical Drives** > **Remove disk from virtual drive** while the machine is restarting.

> [!TIP]
> **Stuck on a black screen?**
> Don't panic! Navigate to the top menu bar, go to **Machine** > **Reset**. When the system reboots, simply select the first option (**Arch Linux**) from the boot menu to start your OS.

> [!CAUTION]
> **Login Failures & Missing User Profile**
> If your system does not recognize your custom username or you encounter login errors, use **`root`** as the username and enter the password you created during the installation. This will grant you access to the system, allowing you to manually fix user configurations or proceed with the setup.

-----

## ⌨️ 5. System Language and Layout Settings
Click the status area in the top-right corner as shown in the image. Then, select the gear icon (Settings) that appears to open the system configuration menu.

<img width="1278" height="800" alt="image" src="https://github.com/user-attachments/assets/ca8bbe7a-4bf4-46e1-8fc2-49b1f6bc5664" />

**Language & Formats:**

1.  **Scroll down** the left sidebar until you find the **System** section.
2.  Click on the first entry: **Region & Language**.
3.  *Language:* sets the text shown in menus and apps.
4.  *Formats:* sets the date, time, and currency based on your region.
   
-----

## 🚀 6. Deployment

For the final deployment and to run the **ArchZero-Cyber** script, please consult the **[README.md](README.md)** file and follow the Quick Start procedure.

---

## 📜 Authorship & Credits

This guide was originally created and structured by **Tony-ScarFace**. 
You are welcome to use, share, or adapt this documentation, provided that you give **proper attribution** by explicitly crediting the author and linking back to this repository.
