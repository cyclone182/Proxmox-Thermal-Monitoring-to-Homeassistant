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
    └── 📄 automations.yaml      <-- (Closed-loop throttling logic)
