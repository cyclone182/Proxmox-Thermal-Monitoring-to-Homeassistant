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
