# Minecraft Server Security and Hardening

This document describes the security measures used to protect the Minecraft server, the Windows host, the Tailnet, and the Minecraft world.

The objective is not to make the system "impossible to attack"—no Internet-connected system can guarantee that—but to minimize unnecessary exposure and provide multiple independent security layers.

---

## 1. Security Philosophy

The server follows a **defense-in-depth** approach.

Instead of relying on one security mechanism, multiple layers are used:

```text id="h2v8kw"
                 Tailnet
                    │
                    ▼
             Network Access
                    │
                    ▼
            Windows Firewall
                    │
                    ▼
             Minecraft Server
                    │
                    ▼
              Whitelist
                    │
                    ▼
                 Players
```

If one layer fails, the other layers still provide protection.

---

# 2. No Public Port Forwarding

The most important security decision was **not forwarding Minecraft port `25565` through the home router**.

Traditional public hosting would look like:

```text id="7l8x3s"
Internet
   │
   ▼
Public IP
   │
   ▼
Router
   │
   └── Port 25565
          │
          ▼
       Minecraft
```

The current setup instead uses:

```text id="v1s3ka"
Friend
   │
   ▼
Tailscale
   │
   ▼
Tailnet
   │
   ▼
Minecraft Host
```

This means Minecraft does not need to be exposed as a publicly reachable service.

### Why this matters

A publicly exposed service can be discovered and probed by arbitrary Internet hosts.

By keeping Minecraft inside the Tailnet, access is restricted before traffic even reaches the Minecraft application.

---

# 3. Windows Firewall Must Remain Enabled

Windows Firewall should remain enabled.

It should **not** be disabled simply because Minecraft or Tailscale is having connection problems.

A common but bad troubleshooting method is:

```text
Minecraft doesn't connect
        ↓
Disable firewall
        ↓
It works
        ↓
Leave firewall disabled
```

This may solve the immediate problem while creating a much larger security problem.

The correct approach is:

```text
Minecraft doesn't connect
        ↓
Determine which layer is failing
        ↓
Create/modify the minimum required rule
        ↓
Test again
```

---

# 4. Principle of Least Exposure

The server should expose as little as possible.

The desired state is:

```text
Public Internet
      │
      X
      │
      └── Minecraft unavailable
              │
              ▼
          Tailnet only
              │
              ▼
        Minecraft :25565
```

The goal is not to expose every service and then try to protect it.

The goal is to **avoid exposing unnecessary services in the first place**.

---

# 5. Minecraft Port 25565

Minecraft Java Edition normally listens on:

```text
25565
```

This does not mean the port must be publicly accessible.

In the current architecture, the port is reachable through the appropriate network interface rather than through a router port-forwarding rule.

The important distinction is:

```text
Port ≠ Public Internet exposure
```

A port simply identifies a network service.

Whether that service is publicly reachable depends on the network path and firewall configuration.

---

# 6. Tailscale as the Network Security Boundary

Tailscale acts as the first major access boundary.

The intended model is:

```text
Unknown Internet device
        │
        X
        │
        ▼
      Tailnet
        │
        ▼
Authorized device
        │
        ▼
Minecraft server
```

A person knowing the Minecraft server's Tailscale IP is not enough by itself.

They also need appropriate access to the Tailnet.

---

# 7. Tailscale Account Security

The Tailscale account controlling the server network is extremely important.

If an unauthorized person gains control of the account managing the Tailnet, they could potentially gain access to the private network.

Therefore:

* Use a strong, unique account password where applicable.
* Protect the identity provider account used to sign in.
* Enable multi-factor authentication when available.
* Do not share account credentials.
* Do not give administrative access unnecessarily.
* Remove devices that are permanently retired or no longer trusted.

The security of the Tailnet ultimately depends partly on the security of the accounts controlling it.

---

# 8. Do Not Share Authentication Secrets

The following should never be published to GitHub:

```text
Passwords
API keys
Authentication tokens
Private keys
Recovery codes
Tailscale authentication secrets
Cloud credentials
Database credentials
```

Even if a secret is accidentally deleted from the latest Git commit, it may still exist in Git history.

Therefore:

> Treat credentials as secrets, not configuration files.

---

# 9. Minecraft Whitelist

The Minecraft whitelist provides application-level access control.

Enable it with:

```text id="l3qf08"
whitelist on
```

Add a player:

```text id="mb1d5a"
whitelist add PlayerName
```

View the whitelist:

```text id="0a1q6u"
whitelist list
```

Remove a player:

```text id="kdb1j9"
whitelist remove PlayerName
```

This creates another authorization layer after network access has already been established.

---

# 10. Whitelist vs Tailscale

These two mechanisms solve different problems.

### Tailscale

Answers:

> "Can this device reach the private network?"

### Minecraft whitelist

Answers:

> "Can this Minecraft account join the server?"

Therefore:

```text id="x7s8nv"
Device authorization
        ↓
     Tailscale
        ↓
Network access
        ↓
Minecraft
        ↓
Whitelist
        ↓
Player authorization
```

Using both is stronger than relying on either one alone.

---

# 11. Server Operator Permissions

Minecraft operator permissions should be treated carefully.

An operator can perform powerful server commands.

For example:

```text id="h8y5uj"
op PlayerName
```

should not be given casually.

Avoid giving every player operator privileges simply because they are friends.

A normal player should remain a normal player.

Only trusted administrators should receive elevated Minecraft permissions.

---

# 12. Console Access Is Powerful

Anyone who can directly control the server console can potentially control the Minecraft server.

For example:

```text id="4e2z3j"
stop
```

can shut down the server.

Other commands can modify players, permissions, worlds, and gameplay.

Therefore, the Windows account hosting the server should also be protected.

The Minecraft server's security is partly dependent on the security of the operating system running it.

---

# 13. Windows Account Security

The Windows host should have:

* A secure login
* Current Windows security updates
* Antivirus/Windows Security enabled
* Firewall enabled
* No unnecessary administrator access for other users
* No unnecessary remote-access services exposed to the Internet

Minecraft does not need unrestricted administrator privileges to operate.

---

# 14. Keep Java and Server Software Updated

The server depends on Java and Minecraft server software.

Updates can contain:

* Security fixes
* Bug fixes
* Compatibility improvements
* Performance improvements

However, updates should not be installed blindly immediately before important gameplay sessions.

A good maintenance approach is:

```text
Backup
   ↓
Update
   ↓
Start server
   ↓
Check logs
   ↓
Test
   ↓
Continue playing
```

This reduces the risk of losing the working configuration after an update.

---

# 15. Backups Are a Security Measure

Backups are not only for hardware failures.

They also protect against:

* Accidental deletion
* Corrupted chunks
* Incorrect commands
* Bad configuration changes
* Plugin or mod problems
* Failed updates
* User mistakes

The Minecraft world is one of the most valuable server assets.

The server software can be downloaded again.

The world cannot necessarily be recreated.

---

# 16. What Should Be Backed Up?

At minimum, preserve the Minecraft world directories.

Depending on the server configuration, this may include:

```text
world/
world_nether/
world_the_end/
```

Also consider backing up important configuration files such as:

```text
server.properties
whitelist.json
ops.json
banned-players.json
banned-ips.json
```

The exact files present depend on the server configuration.

---

# 17. Backup Before Major Changes

Before performing any of the following:

* Minecraft version upgrade
* Java upgrade
* Configuration changes
* Changing major networking configuration

create a backup.

A safe change sequence is:

```text
Working Server
      │
      ▼
Full Backup
      │
      ▼
Change
      │
      ▼
Testing
      │
      ├── Success → Continue
      │
      └── Failure → Restore Backup
```

---

# 18. GitHub Security

The repository is intended for documentation and safe configuration examples.

It should **not** become a backup of the live server containing private data.

Do not commit:

```text
world/
logs/
crash-reports/
usercache.json
server logs containing sensitive information
credentials
authentication tokens
private configuration
```

The repository should contain documentation and safe configuration examples rather than the entire live server.

---

# 19. Recommended `.gitignore`

A `.gitignore` should prevent accidental commits of runtime data.

A basic example:

```gitignore id="n2q6mt"
# Minecraft runtime data
logs/
crash-reports/
world/
world_nether/
world_the_end/

# Local server files
*.log

# Potentially sensitive files
*.key
*.pem
*.token

# Backups
backups/

# Operating system files
Thumbs.db
Desktop.ini

# IDE/editor files
.vscode/
.idea/
```

Adjust the exact contents to the server's needs.

---

# 20. Never Use GitHub as the Only Backup

GitHub and Minecraft backups serve different purposes.

### GitHub

Useful for:

* Documentation
* Scripts
* Configuration templates
* Operating procedures
* Setup instructions

### World backup

Useful for:

* Recovering the actual Minecraft world
* Recovering player progress
* Recovering after corruption

Therefore:

```text
GitHub ≠ World Backup
```

Both can exist, but they serve different purposes.

---

# 21. Server Shutdown Safety

Never routinely shut the server down by force.

Preferred method:

```text
stop
```

Minecraft then has an opportunity to save its data correctly.

Avoid repeatedly doing:

```text
Kill Java process
```

or:

```text
Close PowerShell
```

while the server is actively writing world data.

An unexpected termination can increase the risk of data corruption.

---

# 22. Hardware Failure

The laptop itself is another potential failure point.

Possible failures include:

* SSD failure
* Windows corruption
* Power loss
* Overheating
* Accidental deletion
* Hardware damage

This is why backups should exist somewhere other than the live server directory.

The general principle is:

> If the only copy of the world is on the server, it is not a backup.

---

# 23. Power and 24/7 Hosting

The current server is hosted on a laptop.

For temporary hosting, this is practical.

For permanent 24/7 hosting, additional considerations become important:

* Heat
* Power consumption
* Battery health
* Windows updates
* Sleep settings
* Unexpected restarts
* Internet availability

Choose hosting hardware and power settings that suit the required availability, while accounting for heat, power use, and reliability.

---

# 24. Tailscale Device Management

The Tailnet device list should periodically be reviewed.

Remove devices that:

* Are permanently unused
* Belong to people who should no longer have access
* Have been compromised
* Were only temporarily added
* Are no longer under the owner's control

A private network is only as trustworthy as the devices and accounts allowed into it.

---

# 25. What Happens If a Friend Changes Minecraft Username?

This is one reason whitelist management can become inconvenient.

Minecraft's modern account identity system does not always behave like a simple permanent username list.

If a trusted friend changes their account name, the whitelist may need to be updated depending on the server/account state.

The important lesson is:

> Do not assume that a player's visible username is the same thing as their permanent identity.

This is also why the whitelist should be maintained deliberately rather than copied blindly between servers.

---

# 26. Security Incident Response

If the server behaves suspiciously:

### Step 1 — Stop the server

```text
stop
```

### Step 2 — Disconnect suspicious devices from the Tailnet

Use the Tailscale administration interface.

### Step 3 — Review recent server activity

Check:

```text
logs/
```

### Step 4 — Review the whitelist

```text
whitelist list
```

### Step 5 — Review operator permissions

Check who has elevated Minecraft permissions.

### Step 6 — Restore from a known-good backup if necessary.

### Step 7 — Change compromised credentials

If an account or secret may have been compromised, rotate it.

---

# 27. What This Security Model Protects Against

The architecture substantially reduces exposure to:

* Random Internet connection attempts
* Public Minecraft port scanning
* Unwanted public players
* Unnecessary router exposure
* Accidental public hosting
* Unauthorized Tailnet devices, assuming Tailnet access is properly controlled

---

# 28. What It Does NOT Protect Against

Tailscale is not magic.

It does not automatically protect against:

* A compromised friend's computer
* A compromised Tailscale account
* Someone with legitimate server access
* Malware on the Windows host
* Accidental deletion
* Minecraft bugs
* World corruption
* SSD failure
* Power failure
* Deliberate griefing by an authorized player

This is why security must include both **technical controls and trusted-user management**.

---

# 29. Final Security Architecture

The complete security model is:

```text
                         INTERNET
                            │
                 ┌──────────┴──────────┐
                 │                     │
          Unauthorized              Authorized
             Device                    Friend
                 │                     │
                 X                     ▼
                 │                  Tailscale
                 │                     │
                 │                     ▼
                 │                   Tailnet
                 │                     │
                 │                     ▼
                 │              Windows Firewall
                 │                     │
                 │                     ▼
                 │             Minecraft :25565
                 │                     │
                 │                     ▼
                 │                Whitelist
                 │                     │
                 │                     ▼
                 │                   Player
                 │
                 └── BLOCKED
```

This is the fundamental security architecture for this server.

---


For a small private Minecraft server, the combination of:

```text
Tailscale
+
Windows Firewall
+
Minecraft Whitelist
+
Protected Windows Account
+
Protected Tailscale Account
+
Regular Backups
```

provides a strong and practical security baseline without unnecessarily complicating the server.

Security is not a single setting.

It is the combination of all these layers working together.