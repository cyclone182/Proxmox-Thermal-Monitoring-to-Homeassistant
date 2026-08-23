# Proxmox to Home Assistant Thermal Monitoring

This project provides a lightweight, agentless solution to monitor CPU and drive temperatures across a multi-node Proxmox Virtual Environment (PVE) cluster and display them in Home Assistant. It is optimized for Intel NUC clusters (specifically tested on 8th Gen NUC8i5BEH and NUC8i7BEH) but can be easily adapted to other hardware.

Instead of installing heavy monitoring agents on the Proxmox hosts, this approach uses simple bash scripts on the nodes and leverages Home Assistant's native command-line sensor integration via SSH.

## Features
*   **Agentless:** No heavy services or Docker containers running on Proxmox.
*   **Hardware Agnostic:** Includes scripts for standard NVMe drives (via `lm-sensors`) and SATA/Virtual controllers (via `smartmontools`).
*   **Clean JSON Output:** Proxmox nodes output metrics natively in JSON format, preventing parsing errors in Home Assistant.
*   **Native HA Dashboards:** Includes YAML for a modern, gauge-style dashboard sub-view using built-in Home Assistant cards.
*   **Smart Alerts:** Includes an automation to notify via Pushover if sustained thermal throttling zones are reached, avoiding "alert fatigue."

---

## Repository Structure

```text
📁 proxmox-ha-thermal-monitor/
│
├── 📄 README.md                 
│
├── 📁 proxmox_scripts/
│   ├── 📄 ha_metrics_nvme.sh    <-- (Use for nodes with standard NVMe drives)
│   └── 📄 ha_metrics_sata.sh    <-- (Use for nodes with SATA or virtualized drives)
│
└── 📁 home_assistant/
    ├── 📄 sensors.yaml          <-- (HA command-line and template sensors)
    ├── 📄 dashboard.yaml        <-- (Grid card UI code)
    └── 📄 alerts.yaml           <-- (Pushover automation code)
```

---

## 1. Prerequisites

### ⚠️ CRITICAL: Install Required Sensor Packages
**You MUST install `lm-sensors` on your Proxmox nodes.** If this package is missing, the bash scripts will fail to read the NVMe temperatures and will output errors instead of clean data.

Run the following command on *each* Proxmox node's shell to install both `lm-sensors` and `smartmontools` (needed for SATA drives):
```bash
apt update && apt install lm-sensors smartmontools -y
```

Once installed, you must run the automated detection tool so Linux can map your motherboard's thermal zones:
```bash
sensors-detect --auto
```

### 🛡️ Security Best Practice: Restrict SSH Access
Home Assistant must be able to SSH into your Proxmox nodes without a password. First, generate an RSA key inside your Home Assistant `/config/.ssh` directory. 

When appending the public key to the `/root/.ssh/authorized_keys` file on each Proxmox node, **do not grant full root access**. Instead, prepend command restrictions to the public key so it can *only* execute the metrics script. 

Your entry in `/root/.ssh/authorized_keys` should look like this (replace `ssh-rsa AAAAB3...` with your actual public key):
```text
command="/usr/local/bin/ha_metrics.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1...
```
*This ensures that even if your Home Assistant instance is compromised, the SSH key cannot be used to gain a root shell or alter your Proxmox hypervisor.*

---

## 2. Proxmox Node Setup

1. Choose the appropriate bash script from the `/proxmox_scripts` directory based on your node's hardware. 
2. Create the script on your Proxmox node:
   ```bash
   nano /usr/local/bin/ha_metrics.sh
   ```
3. Paste the contents of the chosen script and save the file.
4. Make the script executable:
   ```bash
   chmod +x /usr/local/bin/ha_metrics.sh
   ```
5. Repeat for all nodes in your cluster.

---

## 3. Home Assistant Configuration

### Sensors
Copy the YAML configuration from `home_assistant/sensors.yaml` into your Home Assistant `configuration.yaml` file. 

**Important:** Update the IP addresses in the SSH commands to match your Proxmox nodes, and ensure the path to your SSH key (`-i /config/.ssh/proxmox_key`) is correct.

### Dashboard UI
To create the visual gauges, create a new **Grid Card** in your Home Assistant dashboard, switch to the **Code Editor**, and paste the contents of `home_assistant/dashboard.yaml`. The severity color bands are pre-tuned for the thermal limits of 8th Gen Intel NUCs.

### Automations
To receive thermal alerts, create a new automation in Home Assistant, switch to the YAML editor, and paste the contents of `home_assistant/alerts.yaml`. 

This automation monitors the sensors and sends a Pushover notification only if a component remains in a high-temperature state for over 5 minutes (CPU >= 190°F, NVMe >= 155°F).
