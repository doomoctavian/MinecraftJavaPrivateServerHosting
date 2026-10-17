## 1.1 Introduction

This guide describes a self-hosted **Minecraft Java Edition Vanilla server** for a small private group of approximately 4–6 players.

The server is hosted on a Windows 11 laptop and uses **Tailscale** to provide private network connectivity between the server and players.

The primary design goal is to allow remote multiplayer without exposing the Minecraft server directly to the public internet through traditional router port forwarding.

The guidance covers:

* Network security
* Privacy
* Reliability
* Simple administration
* Troubleshooting
* World safety
* Routine operation and recovery

---

# 1.2 Why Private Networking Matters

A Minecraft server hosted on a home computer normally exists behind a private local network.

For example:

```text
Minecraft Server
       │
       ▼
192.168.1.73
       │
       ▼
Home Router
       │
       ▼
Internet
```

A device outside the home network normally cannot directly access:

```text
192.168.1.73
```

because private IP addresses such as `192.168.x.x` are not directly routable across the public internet.

The traditional solution is to configure **port forwarding** on the router.

For Minecraft, this commonly means forwarding:

```text
TCP 25565
```

from the router to the server.

Although this works, it creates an externally reachable service and introduces additional router and network configuration.

Tailscale is an alternative to public router port forwarding.

---

# 1.3 Guide Scope

This guide explains how to run a Vanilla server for approximately 4–6 players, connect remotely without Minecraft port forwarding, apply multiple layers of access control, and maintain the server and its world locally.

---

# 1.4 Design Philosophy

Use these principles when setting up and operating the server.

### Principle 1 — Keep the server under local control

The Minecraft world and server configuration are stored locally rather than depending on a third-party Minecraft hosting provider.

---

### Principle 2 — Minimize public exposure

There is no need to expose Minecraft's port to the entire internet when the server is intended for a small group of known players.

Therefore, the design avoids traditional port forwarding.

---

### Principle 3 — Use multiple security layers

Security should not depend on one mechanism.

The system combines:

```text
Tailscale
    ↓
Windows Firewall
    ↓
Minecraft Server
    ↓
Minecraft Whitelist
```

Each layer has a different responsibility.

---

### Principle 4 — Separate networking from the application

Minecraft should not need to know how the players reach the host.

Minecraft continues listening on:

```text
25565
```

Tailscale provides the private network path to the host.

This separation makes the architecture easier to understand and troubleshoot.

---

# 1.5 System Components

The final system consists of several major components.

## Minecraft Server

The Minecraft server is the actual game server.

It is responsible for:

* World simulation
* Player connections
* Entity management
* Game rules
* Commands
* Permissions
* World storage
* Player data

The server runs using the official Vanilla Minecraft server software.

---

## Java

The Minecraft server is a Java application.

Java provides the runtime environment required to execute:

```text
server.jar
```

The server is launched using:

```powershell
java -Xms2G -Xmx4G -jar server.jar nogui
```

---

## Windows 11

Windows is currently used as the server host operating system.

It provides:

* Hardware access
* Networking
* File storage
* Process management
* Windows Firewall
* Power management

---

## Tailscale

Tailscale provides the private networking layer.

It allows participating devices to communicate using private Tailscale addresses.

Example:

```text
100.118.69.26
```

Tailscale is based on WireGuard technology and provides encrypted communication between participating devices.

---

## Tailnet

The Tailnet is the private network containing the authorized Tailscale devices.

Conceptually:

```text
                 Tailnet
                    │
        ┌───────────┼───────────┐
        │           │           │
      Host       Friend 1    Friend 2
   100.x.x.x    100.x.x.x    100.x.x.x
```

The Tailnet effectively creates a private networking layer over existing internet connections.

---

## Windows Firewall

Windows Firewall controls which network traffic is allowed to reach the host.

It provides an additional security boundary between the network and applications running on the computer.

The firewall should be configured to allow only the required traffic rather than being disabled completely.

---

## Minecraft Whitelist

The Minecraft whitelist provides application-level access control.

Even if a device can reach the Minecraft server, the Minecraft account still needs to be authorized if the whitelist is enabled.

This creates another layer:

```text
Network access
      ↓
Minecraft access
      ↓
Authorized player
```

---

# 1.6 Network Architecture

The complete architecture is:

```text
                          INTERNET
                              │
             ┌────────────────┴────────────────┐
             │                                 │
       Host's Network                    Player's Network
             │                                 │
             ▼                                 ▼
     ┌───────────────┐                 ┌───────────────┐
     │ Windows 11    │                 │ Player PC     │
     │ Host Laptop   │                 │               │
     │               │                 │ Minecraft     │
     │ Minecraft     │                 │ + Tailscale   │
     │ Server        │                 └───────┬───────┘
     │               │                         │
     │ TCP 25565     │                         │
     │               │                         │
     │ Tailscale     │◄────────────────────────┘
     │ 100.x.x.x     │
     └───────┬───────┘
             │
             ▼
        Private Tailnet
             │
       Encrypted tunnel
```

The important architectural decision is that the router does **not** need a Minecraft port-forwarding rule.

---

# 1.7 LAN Address vs Tailscale Address

The host computer can have multiple network addresses.

For example:

```text
192.168.1.73
```

may represent the host's local network address.

Meanwhile:

```text
100.118.69.26
```

represents its Tailscale address.

These addresses have different purposes.

### Local LAN

```text
192.168.1.73
```

This is normally reachable by devices connected to the same physical home network.

### Tailscale

```text
100.118.69.26
```

This is reachable by devices that can communicate with the host through the Tailnet.

Therefore, a remote player using Tailscale should connect using:

```text
100.118.69.26:25565
```

rather than:

```text
192.168.1.73:25565
```

---

# 1.8 Why Port 25565 Still Exists

Avoiding port forwarding does **not** mean Minecraft stops using port 25565.

Minecraft still runs normally:

```text
Minecraft Server
      │
      ▼
TCP 25565
```

The difference is how the connection reaches the computer.

### Traditional setup

```text
Public Internet
      ↓
Public IP
      ↓
Router
      ↓
Port Forward
      ↓
Host
      ↓
Minecraft :25565
```

### Tailscale setup

```text
Tailscale
      ↓
Tailnet
      ↓
Host
      ↓
Minecraft :25565
```

Tailscale changes the **network path**, not the Minecraft protocol or server port.

---

# 1.9 Tailscale as an Overlay Network

Tailscale can be understood as an **overlay network**.

The physical networks remain unchanged.

For example:

```text
Friend's Wi-Fi
      │
      ▼
   Internet
      │
      ▼
Tailscale
      │
      ▼
   Tailnet
      │
      ▼
Tailscale
      │
      ▼
Host's Wi-Fi
      │
      ▼
Minecraft
```

The overlay network sits on top of the existing internet infrastructure.

This allows devices that are physically separated to communicate as members of a private virtual network.

---

# 1.10 Direct Connections and Relays

Tailscale attempts to establish direct connections between devices when network conditions allow it.

Conceptually:

```text
Player
   │
   │ Direct encrypted connection
   │
   ▼
Minecraft Host
```

If a direct connection cannot be established because of restrictive NAT or firewall conditions, Tailscale can use a relay mechanism.

Conceptually:

```text
Player
   │
   ▼
Tailscale Relay
   │
   ▼
Minecraft Host
```

A direct connection is generally preferable for performance.

However, Tailscale's networking layer is designed to handle situations where direct connectivity is difficult.

---

# 1.11 Port Forwarding vs Tailscale

The two approaches solve the same basic problem—allowing remote players to reach the server—but they do it differently.

| Feature                         | Port Forwarding  | Tailscale            |
| ------------------------------- | ---------------- | -------------------- |
| Minecraft port publicly exposed | Yes              | No                   |
| Router configuration            | Required         | Usually not required |
| Private overlay network         | No               | Yes                  |
| Encrypted tunnel                | Not inherently   | Yes                  |
| Public IP required by players   | Usually          | No                   |
| NAT traversal                   | Router-dependent | Built into Tailscale |
| Public attack surface           | Higher           | Lower                |
| Setup complexity                | Moderate         | Low                  |
| Direct connections possible     | Yes              | Yes                  |
| Relay possible                  | No               | Yes                  |
| Minecraft configuration         | Mostly unchanged | Mostly unchanged     |

Tailscale is therefore particularly suitable for a small private server where the players are known and trusted.

---

# 1.12 Performance Considerations

Tailscale should not be considered automatically faster than port forwarding.

Performance depends on the actual network path.

With a direct Tailscale connection:

```text
Player
   │
   └──────────────► Host
```

the traffic can travel directly between the devices after the secure connection is established.

If a relay is required:

```text
Player
   │
   ▼
Relay
   │
   ▼
Host
```

additional latency may be introduced.

Therefore:

> The primary reasons to choose Tailscale are security, privacy, and simplicity—not raw network speed.

---

# 1.13 Security Architecture

The server uses defense in depth.

```text
                  External Internet
                         │
                         ▼
                ┌────────────────┐
                │    Tailscale   │
                │    Tailnet     │
                └───────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │ Windows Firewall│
               └───────┬─────────┘
                       │
                       ▼
               ┌─────────────────┐
               │ Minecraft Server│
               │     :25565      │
               └───────┬─────────┘
                       │
                       ▼
                 Minecraft
                  Whitelist
                       │
                       ▼
                Authorized Player
```

This means an unauthorized user must overcome multiple layers before gaining meaningful access.

---

# 1.14 Hardware Requirements

The server does not require extremely powerful hardware for a small Vanilla world.

For a 4–6 player server, a practical configuration includes:

### Minimum practical host

* Modern multi-core CPU
* 8 GB RAM
* SSD storage
* Stable internet
* Java runtime

### Recommended host

* Modern 4+ core CPU
* 16 GB RAM
* SSD
* Stable wired or strong Wi-Fi connection
* Reliable power

The current host has:

```text
Intel Core i7-13620H
16 GB RAM
512 GB SSD
Windows 11
```

which provides considerable headroom for the intended workload.

---

# 1.15 Internet Requirements

Minecraft does not generally require huge bandwidth for a small number of players.

Latency and stability are usually more important than having extremely high bandwidth.

Important factors include:

* Upload speed
* Download speed
* Ping
* Packet loss
* Connection stability
* Wi-Fi reliability
* ISP behavior

Because the server is self-hosted, **upload bandwidth** is particularly important.

The host must send world and gameplay information to connected players.

---

# 1.16 Reliability Considerations

A self-hosted server is only available while the host is available.

If the laptop is:

```text
Powered off
```

or:

```text
Disconnected from the internet
```

the Minecraft server is unavailable.

To improve reliability, consider:

* Automatic server startup
* Automated backups
* Power management
* Monitoring
* Better recovery procedures
* A host and power configuration suited to the expected availability

---

# 1.17 World Safety

The Minecraft world is the most important piece of persistent server data.

The server may contain:

```text
world/
world_nether/
world_the_end/
```

These directories contain the persistent Minecraft world.

They should therefore be backed up before:

* Minecraft version upgrades
* Server configuration changes
* Major experiments
* Installing modifications
* Other potentially destructive operations

GitHub should not be treated as the primary backup mechanism for the world.

---

# 1.18 Troubleshooting Philosophy

When something fails, the system should be tested layer by layer.

Instead of immediately changing random settings, identify which layer is failing.

```text
Is Minecraft running?
        │
        ▼
Does the host have a Tailscale IP?
        │
        ▼
Is Tailscale running?
        │
        ▼
Can the devices communicate through Tailscale?
        │
        ▼
Does Windows Firewall allow the traffic?
        │
        ▼
Is Minecraft listening on port 25565?
        │
        ▼
Is the player authorized?
```

This approach prevents unrelated components from being changed unnecessarily.

---

# 1.19 Practical Operating Guidance

Keep these operational distinctions in mind:

### Minecraft and Tailscale should be tested separately

A Minecraft connection failure does not automatically mean that Tailscale is broken.

Likewise, successful Tailscale connectivity does not guarantee that Minecraft is accepting connections.

These should be treated as separate layers.

---

### `tailscale status` is extremely useful

The command:

```powershell
tailscale status
```

can quickly reveal whether devices are:

```text
online
offline
```

and can help identify which machine is responsible for a connectivity problem.

---

### `tailscale ping` is a networking diagnostic

The command:

```powershell
tailscale ping <IP>
```

can be used to test connectivity between Tailscale devices independently of Minecraft.

If it fails, investigate Tailscale/networking before changing Minecraft configuration.

---

### LAN and Tailscale addresses should not be confused

For example:

```text
192.168.1.73
```

and:

```text
100.118.69.26
```

may refer to the same physical computer but belong to completely different networking contexts.

Understanding this distinction makes troubleshooting easier.

---

# 1.20 Reference Setup

The examples in this documentation use a Windows 11 host, Java, a Vanilla server, and Tailscale. The reference setup is intended for a small private group and uses the Minecraft whitelist without router port forwarding.

---

# 1.21 Summary

The reference setup uses a relatively simple architecture:

```text
Minecraft
    │
    ▼
Windows Host
    │
    ▼
Tailscale
    │
    ▼
Private Tailnet
    │
    ▼
Authorized Players
```

The key architectural decision is to use a **private overlay network instead of publicly exposing Minecraft through router port forwarding**.

The result is a server that remains under local control while providing remote multiplayer connectivity to authorized players.

The system is deliberately built in layers so that each component can be independently understood, tested and replaced.

The setup also provides a practical example of:

* Computer networking
* NAT traversal
* VPN/overlay networking
* Firewall configuration
* Linux/Windows-style server administration
* Security architecture
* Troubleshooting
* Infrastructure management