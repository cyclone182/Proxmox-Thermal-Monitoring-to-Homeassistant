# Proxmox to Home Assistant Thermal Monitoring & Governance

This project provides a lightweight, agentless solution to monitor CPU/drive temperatures, track CPU frequency, and actively govern thermal states across a multi-node Proxmox Virtual Environment (PVE) cluster natively in Home Assistant. It is optimized for Intel NUC clusters (specifically tested on 8th Gen NUC8i5BEH and NUC8i7BEH) but can be easily adapted to other hardware.

Instead of installing heavy monitoring agents on the Proxmox hosts, this approach uses simple bash scripts on the nodes and leverages Home Assistant's native command-line integrations via a hardened SSH dispatcher to create a closed-loop thermal throttling system.

## Features
*   **Agentless & Lightweight:** No heavy services or Docker containers running on Proxmox.
*   **Server-Verified State:** Home Assistant tracks the true physical CPU governor state (performance vs. powersave) directly from the kernel, ensuring dashboard accuracy even during network drops.
*   **Closed-Loop Governance:** Automatically forces nodes into low-power states during thermal events and restores performance modes when cooled.
*   **Clean JSON Output:** Proxmox nodes output metrics natively in JSON format, preventing parsing errors in Home Assistant.
*   **Resilient Dashboards:** Includes YAML for a modern, gauge-style dashboard sub-view that gracefully degrades to HTML warning banners if a node goes offline.

---

## Repository Structure

```text
📁 proxmox-ha-thermal-monitor/
│
├── 📄 README.md                 
│
├── 📁 proxmox_scripts/
│   ├── 📄 ha_metrics.sh         <-- (Collects JSON telemetry)
│   ├── 📄 thermal_throttle.sh   <-- (Executes CPU scaling governor changes)
│   └── 📄 ha_dispatcher.sh      <-- (SSH security wrapper / allowlist)
│
└── 📁 home_assistant/
    ├── 📄 configuration.yaml    <-- (HA command-line sensors & switches)
    ├── 📄 templates.yaml        <-- (Attribute extraction sensors)
    ├── 📄 dashboard.yaml        <-- (Grid card UI code)
    ├── 📄 automations.yaml      <-- (Closed-loop throttling logic)
    └── 📄 alerts.yaml           <-- (Pushover thermal alerts logic)
```

---

## 1. Prerequisites

### ⚠️ CRITICAL: Install Required Sensor & CPU Packages
**You MUST install `lm-sensors` and `cpufrequtils` on your Proxmox nodes.** If these packages are missing, the bash scripts will fail to read the NVMe temperatures or alter the CPU governors.

Run the following command on *each* Proxmox node's shell to install the utilities:
```bash
apt update && apt install lm-sensors cpufrequtils -y
```

Once installed, you must run the automated detection tool so Linux can map your motherboard's thermal zones (press ENTER to accept the defaults for all prompts):
```bash
sensors-detect --auto
```

---

## 2. Proxmox Node Setup

### 🛡️ Security Best Practice: Restrict SSH Access
Home Assistant must be able to SSH into your Proxmox nodes without a password. First, generate an RSA key inside your Home Assistant `/config/.ssh` directory. 

When appending the public key to the `/root/.ssh/authorized_keys` file on each Proxmox node, **do not grant full root access**. Instead, prepend command restrictions to the public key so it can *only* execute the `ha_dispatcher.sh` wrapper script, which acts as a strict allowlist. 

Your entry in `/root/.ssh/authorized_keys` should look like this (replace `ssh-rsa AAAAB3...` with your actual public key):
```text
command="/usr/local/bin/ha_dispatcher.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1...
```

### Deploy Scripts
1. Copy all three bash scripts from the `/proxmox_scripts` directory to `/usr/local/bin/` on your Proxmox node.
2. Make all three scripts executable:
   ```bash
   chmod +x /usr/local/bin/ha_metrics.sh /usr/local/bin/thermal_throttle.sh /usr/local/bin/ha_dispatcher.sh
   ```
3. Repeat for all nodes in your cluster.

---

## 3. Home Assistant Configuration

### Sensors & Switches
Copy the YAML configurations from `home_assistant/configuration.yaml` and `home_assistant/templates.yaml` into your respective Home Assistant configuration files. 

**Important:** Update the IP addresses in the SSH commands to match your Proxmox nodes, and ensure the path to your SSH key (`-i /config/.ssh/proxmox_key`) is correct. Restart Home Assistant after adding these.

### Dashboard UI
To create the visual gauges and governance controls, create a new **Manual** view in your Home Assistant dashboard, switch to the **Code Editor**, and paste the contents of `home_assistant/dashboard.yaml`. The severity color bands are pre-tuned for the thermal limits of 8th Gen Intel NUCs. If a node loses connection, the UI will automatically swap the gauges for an offline HTML banner.

### Automations
To enable closed-loop governance, create a new automation in Home Assistant, switch to the YAML editor, and paste the contents of `home_assistant/automations.yaml`. This automation monitors the CPU sensors and automatically forces the respective Proxmox node into `powersave` mode if temperatures exceed 185°F, restoring it to `performance` mode only when temperatures drop below 155°F.

### Thermal Alerts (Pushover)
To receive notifications for sustained high temperatures, add the automation found in `home_assistant/alerts.yaml`. This automation monitors your cluster and sends a Pushover alert if a node's CPU temperature stays above 190°F for 5 minutes, or if an NVMe drive temperature exceeds 155°F for 5 minutes. This delay prevents alert fatigue from brief thermal spikes.

---

## 4. Verification & Testing

Once all files are saved and Home Assistant is restarted, run these checks to ensure the closed-loop governance is functioning:

1. **Toggle Test:** Flip the Manual Override switch for a node in the dashboard. Wait up to 60 seconds (the polling interval) and verify the "Active State" indicator successfully changes between 🚀 Performance Mode and 🔋 Powersave Mode based on server-verified feedback.
2. **Failure Simulation:** Temporarily rename `/usr/local/bin/ha_metrics.sh` on one of the Proxmox nodes to simulate an outage. The dashboard should gracefully replace the node's gauges with the orange "NODE OFFLINE / UNRESPONSIVE" HTML banner without generating rendering errors.
