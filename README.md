# Proxmox Thermal Monitoring & Closed-Loop Governance for Home Assistant

This repository provides a complete, server-verified closed-loop thermal management system for a Proxmox VE cluster (Intel NUCs). It feeds CPU temperature, NVMe temperature, CPU frequency, and the active scaling governor into Home Assistant via secure, passwordless SSH. Home Assistant uses this data to automatically throttle the nodes into `powersave` mode during thermal events and restore them to `performance` mode once cooled.

## Key Features
* **Server-Verified State:** Home Assistant tracks the true physical CPU governor state directly from the kernel, ensuring dashboard accuracy even during network drops.
* **Zero-Agent Telemetry:** Uses native `bash`, `lm-sensors`, and `cpufrequtils` on the host, pushed via a single JSON payload.
* **Secure Execution:** A strict SSH dispatcher wrapper (`ha_dispatcher.sh`) limits Home Assistant to executing only specific telemetry and throttling commands.
* **Resilient Dashboard:** Uses native Home Assistant markdown and conditional cards to gracefully handle node offline states with clean warning banners.

## Prerequisites
* **Proxmox Node:** `lm-sensors` and `cpufrequtils` installed (`apt-get install lm-sensors cpufrequtils`).
* **Home Assistant:** An RSA/Ed25519 SSH keypair generated and stored in `/config/.ssh/proxmox_key`.
