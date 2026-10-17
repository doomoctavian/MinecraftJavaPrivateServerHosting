# Private Minecraft Java Server Without Port Forwarding Using Tailscale

A small private Minecraft server is easiest to understand when its game service and network path are considered separately.

The examples describe Windows 10/11 and a group of invited players. Adapt the settings to the host and verify compatibility with the Minecraft release in use.

## Start here

1. Follow the step by step [Windows server setup guide](docs/windows-server-setup.md) to install Java, create the server, configure it, and connect through Tailscale.
2. Review the [server overview](docs/overview.md) to understand the components and connection path.
3. Use the [Tailscale networking guide](docs/tailscale-networking.md) to understand private connectivity and test the network.
4. Apply the recommendations in the [security guide](docs/security.md).
5. Use the [maintenance guide](docs/maintenance.md) for backups, updates, and routine care.
6. If something does not work, follow the [troubleshooting guide](docs/troubleshooting.md).

The [configuration guide](config/README.md) explains the supplied [`server.properties.example`](config/server.properties.example) template. It is not a live server configuration.

## Architecture

```text
          Player's computer
      ┌───────────────────────┐
      │ Minecraft Java client │
      │ Tailscale             │
      └───────────┬───────────┘
                  │
       Encrypted private connection
             over the Internet
                  │
      ┌───────────▼───────────┐
      │ Windows host          │
      │ Tailscale             │
      │ Minecraft server      │
      │ TCP port 25565        │
      └───────────────────────┘
```

Tailscale forms the private route between the host and devices that have been granted access. Minecraft remains a normal server process on the Windows host and listens on its own port, usually `25565`. The router does not need an inbound Minecraft port-forwarding rule for this arrangement.

The connection has three distinct access checks:

| Layer | Responsibility |
| --- | --- |
| Tailscale | Restricts network reachability to devices with Tailnet access |
| Windows Firewall | Filters traffic reaching the host |
| Minecraft | Authenticates accounts and, when enabled, checks the whitelist |

All players and the host must be online and connected to the appropriate Tailnet while playing. Players use the host's current Tailscale IP and Minecraft port:

```text
<SERVER-TAILSCALE-IP>:25565
```

Find the host's current address with `tailscale ip`; example addresses in the guides are illustrative and should not be copied.

Keep Windows Firewall enabled and use the Minecraft whitelist to control which player accounts can join.

## Starting point

From the directory containing `server.jar`, start the server with:

```powershell
java -Xms2G -Xmx4G -jar server.jar nogui
```

These options set Java's initial and maximum heap sizes. Adjust them for the host's available memory and workload, leaving enough memory for Windows and other applications.

## Repository contents

```text
README.md
docs/
  overview.md
  windows-server-setup.md
  tailscale-networking.md
  security.md
  troubleshooting.md
  maintenance.md
config/
  README.md
  server.properties.example
scripts/
  start-server.bat
  backup-world.bat
screenshots/
  minecraft/
  tailscale/
  windows/
```

The guides explain the service and its operation; the scripts are optional conveniences. Review paths and settings before using a script on your machine.

## Protect server data

Keep the live world, runtime logs, backups, credentials, and other private machine-specific data out of the documentation repository. Store backups separately from the live server and verify that they can be restored. Stop the server cleanly before making a manual copy of the world.

See the [security guide](docs/security.md) and [maintenance guide](docs/maintenance.md) for detailed recommendations.

## Documentation map

| Guide | What it covers |
| --- | --- |
| [Overview](docs/overview.md) | Server components, architecture, networking, and operating principles |
| [Windows setup](docs/windows-server-setup.md) | Java, server files, first launch, configuration, Tailscale, and player access |
| [Tailscale networking](docs/tailscale-networking.md) | Tailnets, addresses, connectivity, relays, and network diagnostics |
| [Security](docs/security.md) | Network exposure, firewall, account access, whitelist, permissions, and data protection |
| [Troubleshooting](docs/troubleshooting.md) | Layer-by-layer diagnosis of startup, connection, and performance issues |
| [Maintenance](docs/maintenance.md) | World backups, updates, storage, logs, and routine checks |
| [Configuration](config/README.md) | Explanation of the example server settings |
## Attribution

Minecraft is a property of Mojang Studios / Microsoft. This documentation is not affiliated with or endorsed by Mojang Studios or Microsoft.
