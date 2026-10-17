# Tailscale Networking and Private Connectivity

This guide explains how to use Tailscale to connect Minecraft players without exposing the Minecraft server directly to the public Internet.

---

## 1. Why Use Tailscale

A traditional Minecraft server can be made accessible from outside the home network using **port forwarding**.

However, port forwarding requires exposing a service on the home router to the public Internet.

For a private server, this approach provides:

* No public Minecraft port
* No router port forwarding
* No public Minecraft IP address
* Encrypted connections between participating devices
* Access limited to devices belonging to the Tailnet
* Easy connectivity for trusted friends

Tailscale provides an overlay network that makes geographically separated devices behave somewhat like they are connected to the same private network.

---

## 2. Traditional Port-Forwarding Architecture

Without Tailscale, a typical Minecraft server looks like:

```text
Friend
   │
   │ Internet
   ▼
Public IP Address
   │
   ▼
Home Router
   │
   │ Port Forward :25565
   ▼
Windows PC
   │
   ▼
Minecraft Server
```

The router receives traffic from the Internet and forwards TCP traffic on port `25565` to the Minecraft server.

This works, but it increases the public attack surface.

---

## 3. Tailscale Architecture

With Tailscale:

```text
Friend's PC
     │
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
Windows Server
     │
     ▼
Minecraft :25565
```

The Minecraft server is accessed through its Tailscale address instead of the home's public IP.

For this server:

```text
Tailscale IP: 100.118.69.26
Minecraft Port: 25565
```

Therefore, a Tailnet-connected player can use:

```text
100.118.69.26:25565
```

---

## 4. What Is a Tailnet?

A **Tailnet** is the private network created by Tailscale for devices belonging to the same Tailscale account/network.

For example:

```text
                 Tailnet
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
    Server        Friend A     Friend B
   Windows PC        PC           PC
       │
       │
       ▼
 Minecraft
```

Devices in the Tailnet receive Tailscale network addresses and can communicate according to the Tailnet's access rules.

The important distinction is:

> Being connected to the Internet does not automatically mean a device can access the Minecraft server.

The device must also have access to the Tailnet.

---

## 5. Tailscale IP Addresses

Tailscale assigns devices addresses from the `100.x.x.x` range.

The Minecraft server received:

```text
100.118.69.26
```

This is different from the laptop's normal LAN address:

```text
192.168.1.73
```

### LAN address

```text
192.168.1.73
```

Used primarily within the local home network.

### Tailscale address

```text
100.118.69.26
```

Used by devices communicating through Tailscale.

### Public IP

The home router may also have a public IP address, but that address does not need to be used for this Minecraft server.

---

## 6. Why `192.168.1.73` Cannot Normally Be Used by Friends

Private LAN addresses such as:

```text
192.168.x.x
10.x.x.x
172.16.x.x – 172.31.x.x
```

are not globally routable over the public Internet.

For example:

```text
Friend in another location
        │
        X
        │
192.168.1.73
```

The friend's computer cannot simply send Internet traffic directly to that address.

Tailscale solves this by creating a private overlay network between participating devices.

---

## 7. Why the `25565` Port Still Exists

A common misconception is:

> "If we aren't port forwarding, why do we still use port 25565?"

Because port forwarding and ports are two different concepts.

Minecraft still needs a port on which the server listens.

The server listens on:

```text
25565
```

The difference is **how traffic reaches that port**.

### Port forwarding

```text
Internet
   ↓
Router :25565
   ↓
Windows :25565
```

### Tailscale

```text
Tailnet
   ↓
Tailscale interface
   ↓
Windows :25565
```

The Minecraft application itself does not need to know whether the traffic arrived through a LAN connection, Tailscale, or another interface.

---

## 8. Tailscale and WireGuard

Tailscale uses **WireGuard** as a core component of its encrypted networking architecture.

WireGuard provides encrypted tunnels between participating devices.

Conceptually:

```text
Friend PC
   │
   │ Encrypted tunnel
   │
   ▼
Tailscale
   │
   │
   ▼
Tailscale
   │
   │ Encrypted tunnel
   ▼
Minecraft Host
```

This means Minecraft traffic is not simply being sent as ordinary unencrypted Internet traffic between the two machines.

---

## 9. Tailscale Is an Overlay Network

Tailscale does not replace the underlying Internet connection.

Instead, it creates another logical network on top of the existing network.

Think of it like this:

```text
Physical Internet
────────────────────────────────

       Your normal network

                ↓

Tailscale Overlay Network
────────────────────────────────

     Friend ───────── Server
```

The physical Internet is still responsible for carrying packets.

Tailscale creates the private networking layer above it.

---

## 10. Direct Connections

When possible, Tailscale attempts to establish a **direct peer-to-peer connection** between devices.

Conceptually:

```text
Friend
   │
   │ Direct encrypted connection
   ▼
Server
```

This is normally preferable because traffic does not need to travel through a Tailscale relay.

A direct connection generally provides better latency and throughput.

---

## 11. NAT Traversal

One of the reasons direct connections are not always trivial is **NAT**.

Most home networks look approximately like:

```text
               Internet
                  │
           Public IP
                  │
              Router
          ┌───────┴───────┐
          │               │
       Laptop           Phone
    192.168.1.x       192.168.1.x
```

The devices inside the home network usually do not have globally routable addresses.

Tailscale uses NAT traversal techniques to attempt to establish connections between devices despite this.

This is one of the major reasons it is easier to use than manually configuring router port forwarding.

---

## 12. Relay Connections

If a direct connection cannot be established, Tailscale can use a relay mechanism.

Conceptually:

```text
Friend
   │
   ▼
Tailscale Relay
   │
   ▼
Server
```

This is less ideal than a direct connection because an additional intermediary is involved.

It can potentially result in:

* Higher latency
* Lower throughput
* Greater dependence on the relay infrastructure

For a small Minecraft server, however, a relay connection may still be perfectly playable.

---

## 13. Direct vs Relay

The important distinction is:

```text
DIRECT

Friend ───────────────── Server
             ↓
       Usually preferred
```

versus:

```text
RELAY

Friend ─── Relay ─── Server
              ↓
       Fallback mechanism
```

Tailscale can determine which connection method is available.

This means the user does not normally need to manually configure every NAT scenario.

---

## 14. Testing Tailscale Independently

One of the most useful troubleshooting commands is:

```powershell
tailscale ping <TAILSCALE-IP>
```

For example:

```powershell
tailscale ping 100.71.255.70
```

This tests Tailscale connectivity rather than Minecraft itself.

This distinction is extremely important.

If:

```text
tailscale ping
```

fails, there is little point debugging Minecraft configuration first.

The networking layer should be fixed first.

---

## 15. Layered Troubleshooting

The server can be viewed as several layers:

```text
Layer 7 ─ Minecraft
Layer 6 ─ Java
Layer 5 ─ Windows
Layer 4 ─ Windows Firewall
Layer 3 ─ Tailscale
Layer 2 ─ Local/Internet Network
```

A Minecraft connection problem should therefore be diagnosed from the bottom upward.

### Step 1 — Is the server running?

Check the Minecraft console.

### Step 2 — Is Java working?

```powershell
java -version
```

### Step 3 — Is Tailscale running?

```powershell
tailscale status
```

### Step 4 — Does Tailscale connectivity work?

```powershell
tailscale ping <IP>
```

### Step 5 — Is the Minecraft port listening?

Check whether Minecraft is listening on port `25565`.

### Step 6 — Is Windows Firewall allowing the required traffic?

Verify firewall rules rather than disabling the firewall.

### Step 7 — Is the player authorized?

Check the Minecraft whitelist.

This prevents random troubleshooting and helps identify exactly which layer is failing.

---

## 16. Tailscale vs Port Forwarding

| Feature                    | Tailscale                  | Port Forwarding                     |
| -------------------------- | -------------------------- | ----------------------------------- |
| Router configuration       | Usually unnecessary        | Required                            |
| Public Minecraft port      | No                         | Yes                                 |
| Public attack surface      | Smaller                    | Larger                              |
| Encryption                 | Tailscale/WireGuard        | Depends on application              |
| Friend setup               | Install/login to Tailscale | Usually simpler for player          |
| Server setup               | More software              | Router configuration                |
| NAT traversal              | Handled by Tailscale       | Handled by router/public networking |
| Direct connection possible | Yes                        | Yes                                 |
| Relay possible             | Yes                        | No                                  |
| Performance                | Usually good               | Usually excellent                   |
| Privacy                    | Better network isolation   | Server publicly reachable           |
| Maintenance                | Tailscale + server         | Router + server                     |
| Access control             | Tailnet + server controls  | Public IP/port + server controls    |

---

## 17. Is Tailscale Faster?

Not inherently.

This is an important tradeoff.

A properly configured direct port-forwarded connection can be extremely efficient.

Tailscale adds an additional networking layer.

However, when Tailscale establishes a direct connection, the performance overhead is generally small enough that a small Minecraft server should not be significantly affected.

The bigger difference appears when Tailscale has to use a relay.

Therefore:

```text
Direct Tailscale
       ≈
Very good performance
```

while:

```text
Tailscale relay
       ↓
Potentially higher latency
```

For a 4–6 player Vanilla Minecraft server, performance is unlikely to be the deciding factor.

Security and convenience are more important.

---

## 18. Privacy Advantages

With port forwarding:

```text
Public Internet
      │
      ▼
Your public IP
      │
      ▼
Port 25565
      │
      ▼
Minecraft
```

Anyone on the Internet can potentially discover and attempt to interact with the exposed service.

With Tailscale:

```text
Public Internet
      │
      X
      │
      └── No public Minecraft port

Trusted Tailnet devices
      │
      ▼
Minecraft
```

This significantly reduces the server's exposure.

It does **not** make the server magically immune to attacks, but it removes an entire class of unnecessary public exposure.

---

## 19. Security Is Layered

Tailscale should not be considered the only security mechanism.

The server uses several layers:

```text
             ┌──────────────────┐
             │     Tailnet      │
             └────────┬─────────┘
                      │
                      ▼
             ┌──────────────────┐
             │ Windows Firewall │
             └────────┬─────────┘
                      │
                      ▼
             ┌──────────────────┐
             │ Minecraft Server │
             └────────┬─────────┘
                      │
                      ▼
             ┌──────────────────┐
             │    Whitelist     │
             └──────────────────┘
```

Each layer has a different purpose.

### Tailscale

Controls network-level access.

### Windows Firewall

Controls traffic entering the host.

### Minecraft

Handles authentication and game-level connections.

### Whitelist

Controls which Minecraft accounts can actually join.

---

## 20. Why Not Just Use the Minecraft Whitelist?

The whitelist is useful, but it should not be treated as a replacement for network security.

Suppose the Minecraft server is publicly exposed.

An attacker could still:

* Discover the server
* Scan the port
* Send connection attempts
* Generate unnecessary traffic
* Probe the exposed service

The whitelist can prevent unauthorized players from joining, but the server is still publicly reachable.

Tailscale reduces the number of machines that can reach the server in the first place.

Therefore:

> **Network-level restriction is preferable to relying only on application-level authorization.**

---

## 21. When Tailscale Is a Suitable Choice

The server is intended for approximately 4–6 trusted friends.

That makes Tailscale particularly suitable.

This setup does not require:

* A public Minecraft server
* Public player discovery
* Thousands of players
* Public server listings
* Router port forwarding
* Internet-wide accessibility

Instead, it needs:

* Private access
* Easy administration
* Secure communication
* Small player count
* Reliable connectivity

Tailscale matches those requirements well.

---

## 22. Limitations

Tailscale is not perfect.

### Players must use Tailscale

Every remote player needs to be connected to the appropriate Tailnet.

### Tailscale becomes another dependency

The Minecraft server can be running perfectly while Tailscale is stopped.

### Relay connections can be slower

If direct connectivity fails, a relay may introduce additional latency.

### Account/network administration matters

Devices and users need appropriate Tailnet access.

### It is not a substitute for backups

Tailscale protects network access.

It does **not** protect the Minecraft world from:

* Corruption
* Accidental deletion
* Bad commands
* Hardware failure
* Disk failure

Backups are still essential.

---

## 23. Final Network Design

The final design can be summarized as:

```text
                        INTERNET
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        Friend's PC              Minecraft Host
              │                         │
          Tailscale                 Tailscale
              │                         │
              └──────────┬──────────────┘
                         │
                      Tailnet
                         │
                         ▼
                  100.118.69.26
                         │
                  Windows Firewall
                         │
                         ▼
                  Minecraft :25565
                         │
                         ▼
                       World
```

There is no need for:

```text
Internet → Router → Port Forward 25565
```

---


The resulting system is essentially a **private Minecraft network for trusted friends rather than a publicly exposed Minecraft server**.