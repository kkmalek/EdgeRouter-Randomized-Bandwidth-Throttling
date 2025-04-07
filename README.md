# 🎛️ EdgeRouter Randomized Bandwidth Throttling (Stealth Mode)

This project implements a randomized, time-based internet throttling system on a **Ubiquiti EdgeRouter 4**, designed to simulate intermittent ISP issues during a configurable time window — perfect for parental control or distraction-reduction without obvious blocking.

---

## ✨ Features

- ✅ **Bidirectional traffic shaping** (upload + download via `tc` + `ifb`)
- 🎲 **Randomized enable/disable cycles** (15–90 min on, 3–10 min off)
- ⏱️ **Active only between midnight and 6:00 AM**
- 🔒 **Failsafe auto-shutdown at 6:01 AM**
- 📊 **Terminal dashboard** for real-time status
- 📜 **Logs all activity** to a file for auditing
- 📦 All scripts are persistent and cron-integrated

---

## 🛠️ Setup Instructions

### 1. Upload scripts to your EdgeRouter

Copy the following files to `/config/scripts/`:

- `wan_throttle.sh` – toggles shaping on/off
- `random_shaper.sh` – runs the randomized logic
- `wan_throttle_dashboard.sh` – terminal-based status display
- `wan_throttle.log` *(created automatically)*

### 2. Make all scripts executable

```bash
chmod +x /config/scripts/*.sh
```

### 3. Ensure the `ifb` module is loaded at boot

Create `/config/scripts/post-config.d/ifb-load.sh`:

```bash
#!/bin/bash
modprobe ifb numifbs=1
```

Then:

```bash
chmod +x /config/scripts/post-config.d/ifb-load.sh
```

### 4. Add Cron Jobs

Run `sudo crontab -e` and add the following:

```cron
# Start random shaper at midnight
0 0 * * * /config/scripts/random_shaper.sh &

# Hard kill backup at 6:01 AM to ensure shaping is disabled
1 6 * * * pkill -f random_shaper.sh && /config/scripts/wan_throttle.sh --off
```

---

## 🧪 Optional Test

Temporarily edit `random_shaper.sh` and change:

```bash
END_HOUR=6
```

to:

```bash
END_HOUR=23
```

Then run:

```bash
/config/scripts/random_shaper.sh &
```

Use this to simulate shaping behavior during the day.

---

## 📋 File Descriptions

| File                          | Description                                               |
|-------------------------------|-----------------------------------------------------------|
| `wan_throttle.sh`             | Toggles upload + download shaping on/off using `tc` and `ifb` |
| `wan_throttle_status.sh`      | Shows current shaping status with color-coded output      |
| `random_shaper.sh`            | Main logic for randomized on/off cycles overnight         |
| `wan_throttle.log`            | Rolling log of all throttle events (auto-generated)       |
| `post-config.d/ifb-load.sh`   | Ensures `ifb` module is available after router reboot      |

---

## 🧠 Why This Works

Linux's `tc` (Traffic Control) can shape egress traffic on any interface. To shape **download traffic**, this setup uses a virtual interface (`ifb0`) to mirror incoming traffic, allowing it to be shaped as if it were outbound. Combined with randomized timing and a stealthy cycle, this creates a pattern that resembles flaky ISP maintenance — not parental control.

---

## ✅ Requirements

- Ubiquiti EdgeRouter 4
- EdgeOS v2.x+
- `tc`, `modprobe`, and `ifb` support (all included by default)

---

## 👏 Credit

This solution was built using Bash scripting, Linux traffic control (`tc`), and old-school stealth thinking. For parents, educators, or productivity hackers who want control without confrontation.
