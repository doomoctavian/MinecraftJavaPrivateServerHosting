# Server Configuration

This directory contains configuration templates and documentation for the Minecraft server.

The configuration is intentionally separated from the live server data.

---

## 1. Directory Purpose

The `config/` directory is for **documenting and tracking configuration**, not for storing the live Minecraft world.

Current structure:

```text
config/
├── server.properties.example
└── README.md
```

The live Minecraft server remains outside this directory.

For the Windows installation:

```text
C:\MinecraftServer\
```

---

# 2. Why Use a `.example` File?

The actual Minecraft configuration is:

```text
server.properties
```

The repository contains:

```text
server.properties.example
```

The `.example` file acts as a reference configuration.

This prevents the GitHub repository from becoming tightly coupled to one specific machine.

The template is independent of the live server's location:

```text
Documentation template
      ↓
Host-specific live configuration
```

The documentation should still remain valid.

---

# 3. Live Configuration vs Repository Configuration

The distinction is:

```text
GitHub Repository
│
└── config/
    └── server.properties.example

Actual Server
│
└── C:\MinecraftServer\
    └── server.properties
```

The repository describes the intended configuration.

The actual server contains the live configuration.

---

# 4. Important Configuration Categories

The Minecraft configuration can broadly be divided into:

```text
Network
Game
World
Players
Performance
Security
Administration
```

Each category affects a different part of the server.

---

# 5. Network Configuration

The most important networking settings include:

```properties
server-port=25565
server-ip=
```

## `server-port`

The default Minecraft Java Edition port is:

```text
25565
```

The server continues to use this port even when Tailscale is being used.

Tailscale changes **how players reach the server**.

It does not replace Minecraft's own port.

The connection path is:

```text
Friend
   ↓
Tailscale
   ↓
Aurelius / Minecraft Host
   ↓
Port 25565
   ↓
Minecraft
```

---

# 6. Why `server-ip` Is Blank

The configuration intentionally uses:

```properties
server-ip=
```

rather than:

```properties
server-ip=100.118.69.26
```

The Tailscale address belongs to a particular host and can change. Hard-coding a temporary or host-specific address would make the configuration less reliable.

Leaving it blank allows Minecraft to listen normally on the available network interfaces.

---

# 7. Tailscale Is Not Configured Through server.properties

Tailscale is a separate networking layer.

Conceptually:

```text
Minecraft
    │
    │ :25565
    ▼
Operating System Network
    │
    ▼
Tailscale
    │
    ▼
Tailnet
```

Therefore, Tailscale configuration should not be mixed into Minecraft's configuration file.

This separation makes troubleshooting easier.

---

# 8. Game Mode

The current server is intended to use:

```properties
gamemode=survival
```

This means newly joining players normally enter Survival mode.

The server can still use commands to temporarily change individual players' modes if the appropriate permissions are available.

---

# 9. Difficulty

The example template uses:

```properties
difficulty=normal
```

The available difficulty levels are:

```text
peaceful
easy
normal
hard
```

Difficulty should be changed only when the players agree on the intended gameplay experience.

---

# 10. Player Limit

The intended group size is approximately:

```text
4–6 players
```

The template therefore uses:

```properties
max-players=6
```

This is not a performance guarantee.

A server configured for six players can still experience performance problems depending on what those players are doing.

For example:

```text
6 players exploring new chunks
```

can be substantially more demanding than:

```text
6 players standing together in an established area
```

---

# 11. Whitelist

The template uses:

```properties
white-list=true
```

The whitelist provides a second authorization layer.

The overall security architecture becomes:

```text
Tailscale access
       ↓
Minecraft server
       ↓
Minecraft whitelist
       ↓
Authorized player
```

Tailscale controls network access.

Minecraft controls player authorization.

These are separate security mechanisms.

---

# 12. Online Mode

The template uses:

```properties
online-mode=true
```

This should normally remain enabled.

Disabling online authentication just to solve a connection problem is not an appropriate troubleshooting method.

If players cannot connect, troubleshoot:

```text
Tailscale
Network
Firewall
Minecraft port
Version
Whitelist
```

instead.

---

# 13. View Distance

The template uses:

```properties
view-distance=16
```

View distance affects how much world data the server sends to players.

Higher values can improve visibility over greater distances but increase server workload.

Conceptually:

```text
Higher view distance
        ↓
More chunks
        ↓
More CPU/RAM/network work
```

---

# 14. Simulation Distance

The example template uses:

```properties
simulation-distance=8
```

Simulation distance controls how far away from players the server actively processes game mechanics.

This can affect:

* Mobs
* Redstone
* Crops
* Other game processes

Reducing simulation distance can lower the server's workload when host resources are limited.

---

# 15. Performance Settings Are Hardware-Dependent

The configuration should not be considered permanently optimal.

Host hardware and player activity affect performance. Treat these values as starting points:

```text
More available resources / lighter activity
                  ↓
         Higher settings may work

Fewer resources / heavier activity
                  ↓
       Lower settings may be needed
```

Measure performance and adjust the settings gradually.

---

# 16. World Configuration

The main world is:

```properties
level-name=world
```

This corresponds to:

```text
world/
```

Additional dimensions are normally associated with the main world.

For an existing world, these folders must be treated as part of the same world state.

Do not casually delete:

```text
world_nether/
world_the_end/
```

---

# 17. World Seed

The template leaves:

```properties
level-seed=
```

blank.

This is intentional.

Once a world already exists, its generated terrain should not be casually changed by modifying the seed in `server.properties`.

The existing world data is what matters.

---

# 18. Structures

The template enables:

```properties
generate-structures=true
```

This allows normal generated structures such as villages and other world-generation structures.

This should normally remain enabled for a conventional Survival world.

---

# 19. Command Blocks

The template uses:

```properties
enable-command-block=false
```

Command blocks are unnecessary for a normal Vanilla Survival server.

If the server configuration or an adventure map requires command blocks, change the setting deliberately.

---

# 20. MOTD

The template uses:

```properties
motd=Private Minecraft Server
```

The MOTD is the message displayed in the Minecraft server list.

It has no major security function.

It can therefore be customized freely.

---

# 21. What Should Be Changed Carefully?

These settings can have significant consequences:

```text
level-name
level-seed
gamemode
difficulty
white-list
online-mode
view-distance
simulation-distance
server-port
server-ip
```

Before changing any of them:

1. Stop the server.
2. Back up the world.
3. Record the previous value.
4. Change the setting.
5. Start the server.
6. Test.

---

# 22. What Should Not Be Changed to Fix Random Problems?

Do not randomly change:

```text
server-port
server-ip
online-mode
```

just because someone cannot connect.

For example, if Tailscale is failing, changing:

```properties
server-port=25565
```

to another arbitrary port does not fix Tailscale.

Troubleshoot the correct layer.

---

# 23. Configuration Change Procedure

The recommended workflow is:

```text
Current configuration
        ↓
Backup
        ↓
Make ONE change
        ↓
Start server
        ↓
Test
        ↓
Keep or revert
```

This creates a clear cause-and-effect relationship.

---

# 24. Configuration and Git

Configuration templates are appropriate for GitHub.

However, live runtime data should remain outside the repository.

Good:

```text
config/server.properties.example
```

Avoid committing:

```text
world/
backups/
logs/
crash-reports/
```

The `.gitignore` file protects against many accidental additions.

---

# 25. Applying the Configuration

Copy only the settings you need from the template to the live `server.properties` file. Review host-specific values before applying them, especially:

```properties
server-ip=
```

and networking-related settings.

---

# 26. Configuration Philosophy

Use three principles when maintaining server configuration:

### 1. Portability

Configuration should not depend unnecessarily on one machine.

### 2. Security

Network exposure should remain minimal.

### 3. Recoverability

Important configuration should be documented and backed up.

The ideal configuration is therefore:

```text
Simple
   +
Documented
   +
Portable
   +
Secure
   +
Recoverable
```

---

# 27. Final Configuration Architecture

```text
GitHub
│
├── config/
│   ├── server.properties.example
│   └── README.md
│
└── Documentation

Actual Server
│
└── C:\MinecraftServer\
    ├── server.jar
    ├── server.properties
    ├── world/
    ├── world_nether/
    ├── world_the_end/
    ├── whitelist.json
    └── ops.json
```

The repository documents the configuration.

The server directory contains the actual live configuration and world.

Keeping those responsibilities separate makes the Minecraft server easier to maintain, troubleshoot, and recover.