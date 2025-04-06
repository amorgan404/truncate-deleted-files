# Cleanup Deleted Files from Java/Tomcat Processes

<div align="center">
    <img src="https://img.shields.io/badge/Shell-Bash-blue?style=flat-square&logo=gnu-bash" alt="Bash Script">
    <img src="https://img.shields.io/badge/Platform-Linux-green?style=flat-square&logo=linux" alt="Linux">
    <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="MIT License">
</div>

## 🧹 Overview

`cleanup_deleted_files.sh` is a lightweight shell script designed to **reclaim disk space** by identifying and truncating deleted files that are still being held open by long-running `java` or `tomcat` processes (such as application logs, temporary JARs, or cache files).

In many production environments, especially with Java-based applications, files that are deleted from disk remain open by processes, causing space not to be released until the process is restarted. This script offers a **safe, automated, and restart-free** way to free up that space.

## 🔍 Problem Statement

When a file is deleted in Linux while a process still has it open, the file system marks it for deletion but keeps the inode allocated until all file handles are closed. This leads to:

- Disk space showing as used but not visible in the file system
- `df` showing high usage while `du` reports lower usage
- Requiring process restarts to fully release space

## ✅ Features

- 🔎 Detects deleted files still held by `java`/`tomcat` processes
- ✂️ Truncates only valid file descriptors safely
- 🛡️ Skips invalid or dangerous entries (like directories)
- 🔒 Prevents self-modification if the script is running
- 🧪 Supports a **dry-run mode** to preview changes without taking action
- ⏱️ Can be scheduled as a **cron job** to prevent disk pressure automatically
- 📊 Provides detailed output of actions taken

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/amorgan404/truncate-deleted-files.git

# Navigate to the directory
cd truncate-deleted-files

# Make the script executable
chmod +x cleanup_deleted_files.sh
```

## 🔧 Usage

### Basic Usage

```bash
./cleanup_deleted_files.sh
```

### 🧪 Dry-run Mode

To simulate the action without truncating any files:

```bash
./cleanup_deleted_files.sh --dry-run
```

You'll see output like:

```
Would truncate: /proc/4760/fd/1
Would truncate: /proc/4760/fd/2
```

## 💡 When to Use

- You notice high disk usage but `du` doesn't reflect it
- `lsof` shows `(deleted)` files held by Java/Tomcat
- You can't restart the service or reboot the server
- You're running a system with uptime-sensitive applications
- You need to recover disk space quickly without service disruption

## ⏱️ Scheduling with Cron

### Run the cleanup daily at midnight:

```bash
0 0 * * * /path/to/cleanup_deleted_files.sh >> /var/log/cleanup_deleted_files.log 2>&1
```

### To run it in dry-run mode:

```bash
0 0 * * * /path/to/cleanup_deleted_files.sh --dry-run >> /var/log/cleanup_deleted_files.log 2>&1
```

## 📊 Example Output

```
Scanning for deleted files held open by java/tomcat processes...
Found deleted file: /var/log/application.log (deleted)
Truncated: /proc/12345/fd/4 (freed 256MB)
Found deleted file: /tmp/tomcat.8080.4918481811358038331.tmp (deleted)
Truncated: /proc/12346/fd/7 (freed 128MB)
Operation completed. Total space freed: 384MB
```

## 🔍 How It Works

1. The script identifies Java and Tomcat processes
2. It examines their open file descriptors
3. For any descriptor pointing to a deleted file, it:
     - Verifies it's a regular file
     - Truncates it to zero bytes using `> /proc/PID/fd/X`
     - Reports the space freed

## 🛠️ Advanced Configuration

You can modify the script to:
- Target additional processes beyond Java/Tomcat
- Add exclusion patterns for specific files
- Implement size thresholds for truncation
- Add notification capabilities

## ✍️ Author

Created with care by Ahmed Morgan.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## ⚠️ Disclaimer

- This script is intended for experienced sysadmins
- Always use `--dry-run` before running it in production
- Use responsibly; truncating active logs may affect monitoring or diagnostics
- Test thoroughly in your environment before deploying to production systems

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
