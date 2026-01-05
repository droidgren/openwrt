

# 💾 Automatic OpenWrt Backup

This script, `backup_on_change.sh`, automatically creates a complete OpenWrt configuration backup (`sysupgrade -b`) to a specified USB mount point any time a watched configuration file is modified.

## Prerequisites

1.  **Mounted External Storage:** You must have a USB drive or other persistent storage mounted to your OpenWrt router (e.g., at `/mnt/sda1`).
      Check the guide there [https://openwrt.org/docs/guide-user/storage/usb-drives-quickstart](https://openwrt.org/docs/guide-user/storage/usb-drives)

-----

## 🚀 Installation

### Step 1: Create Directories and Script File

First, SSH into your OpenWrt router and create the necessary directories.

```bash
# 1. Create the script directory
mkdir -p /root/scripts

# 2. Create the backup destination directory (adjust /mnt/sda1 if needed)
mkdir -p /mnt/sda1/bkps
```

### Step 2: Create the Main Backup Script

Upload the main script file to `/root/scripts/`

[backup_on_change.sh](https://github.com/droidgren/openwrt/blob/main/scripts/autobackup/backup_on_change.sh)

**Set permissions:**

```bash
chmod +x /root/scripts/backup_on_change.sh
```

### Step 3: Configure the Scan Interval and backup location

Edit  the configuration part in top of the script.

```bash
# Configuration
BACKUP_PATH="/mnt/sda1/bkps" # The path to the external drive.
INTERVAL=600 # The time interval in seconds which the script will look for configuration changes (Default is every 10 minutes)
```

### Step 4: Create the `init.d` Service File

Create the service file at `/etc/init.d/backup_on_change` to enable the script to start automatically on boot and be stopped/restarted gracefully.
With the following contents:

[backup_on_change](https://github.com/droidgren/openwrt/blob/main/scripts/autobackup/backup_on_change)

**Set permissions:**

```bash
chmod +x /etc/init.d/backup_on_change
```

## ▶️ Starting and Managing the Service

### Start the Service

Enable the service to start on boot and then start it immediately:

**Note:** These steps can also be done in the GUI under System->Startup

```bash
sed -i 's/\r//' /etc/init.d/backup_on_change
/etc/init.d/backup_on_change enable
/etc/init.d/backup_on_change start
```

### Check Status (Running Processes)

You can confirm the script is running by checking the process list:

```bash
ps w | grep backup_on_change.sh
```

### Stop and Restart the Service

To stop or restart the monitoring service:

```bash
/etc/init.d/backup_on_change stop
/etc/init.d/backup_on_change restart
```

-----

## 🔎 Viewing Logs

All successful backup events and any errors are logged to the system log.

### In LuCI Web Interface

Navigate to **Status** $\rightarrow$ **System Log**. Search for the tag **`backup_watch`**.

### Via SSH

Use the `logread` command and filter by the script's tag:

```bash
logread | grep backup_watch
```
