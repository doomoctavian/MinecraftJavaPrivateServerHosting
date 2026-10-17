# Minecraft Server Maintenance and Reliability

This document describes the procedures for keeping the Minecraft server reliable over the long term.

The initial setup gets the server working. Maintenance keeps it working.

The main goals are:

* Protect the Minecraft world
* Prevent accidental data loss
* Keep software reasonably up to date
* Detect problems early
* Maintain predictable performance
* Make recovery procedures clear

---

# 1. Maintenance Philosophy

A Minecraft server should not require constant attention.

For a small private server, the ideal maintenance model is:

```text
Normal operation
       │
       ▼
Occasional checks
       │
       ▼
Backup
       │
       ▼
Update when necessary
       │
       ▼
Test
       │
       ▼
Return to normal operation
```

The goal is **low-maintenance reliability**, not constant tweaking.

---

# 2. What Actually Needs Maintenance?

The main components are:

```text
Minecraft Server
       │
       ├── World
       ├── Configuration
       ├── Java
       ├── Windows
       ├── Tailscale
       ├── Storage
       └── Backups
```

Each has different maintenance requirements.

---

# 3. World Maintenance

The Minecraft world is the most valuable part of the server.

The server software can be downloaded again.

Java can be reinstalled.

Tailscale can be reinstalled.

The world cannot necessarily be recreated.

Therefore:

> **World preservation is the highest maintenance priority.**

---

# 4. World Backups

A backup should be created regularly.

At minimum, backups should exist before:

* Minecraft version upgrades
* Java upgrades
* Major configuration changes
* Installing mods or plugins
* Any risky troubleshooting

A simple backup architecture is:

```text
Live Server
     │
     ▼
Current World
     │
     ├──────────► Backup 1
     │
     ├──────────► Backup 2
     │
     └──────────► Backup 3
```

Multiple backups are preferable to keeping only one copy.

---

# 5. Backup Rotation

A simple rotation system can be:

```text
backup/
├── latest/
├── previous/
└── monthly/
```

Or backups can be timestamped:

```text
2026-10-01/
2026-10-05/
2026-10-12/
```

Timestamped backups make it easier to identify exactly when a world snapshot was created.

---

# 6. Backup Before Updates

Never make a major change to the server without first creating a backup.

Recommended sequence:

```text
Stop Server
     ↓
Backup World
     ↓
Perform Update
     ↓
Start Server
     ↓
Check Logs
     ↓
Test
```

If the update fails:

```text
Stop Server
     ↓
Restore Backup
     ↓
Return to Previous Version
```

This makes updates reversible.

---

# 7. Clean Server Shutdown

Before creating a world backup, the server should normally be stopped cleanly.

Use:

```text
stop
```

in the Minecraft server console.

Wait until the server has completely shut down.

Then copy the world data.

This reduces the possibility of backing up files while Minecraft is actively changing them.

---

# 8. Why Backing Up a Running World Is Riskier

Minecraft constantly writes world data.

If a backup is created while files are actively changing, the backup may capture an inconsistent state.

For a small private server, the safest simple procedure is:

```text
Stop
 ↓
Backup
 ↓
Start
```

The short interruption is generally worth the additional reliability.

---

# 9. Storage Management

The Minecraft world can grow over time.

World size increases as players:

* Explore new areas
* Generate chunks
* Travel long distances
* Build structures
* Create farms

Therefore, available disk space should occasionally be checked.

The Windows host has a 512 GB SSD, so there is sufficient space for the current small server.

However:

> Available storage should never be allowed to approach zero.

---

# 10. Why Low Disk Space Is Dangerous

A nearly full disk can cause problems beyond Minecraft.

Potential issues include:

* Failed world writes
* Failed backups
* Windows instability
* Log files failing to write
* Temporary-file failures
* Application crashes

Keep a reasonable amount of free space available.

---

# 11. Log Management

Minecraft generates logs under:

```text
logs/
```

Logs are useful for:

* Diagnosing crashes
* Investigating player issues
* Identifying server errors
* Understanding unexpected shutdowns

However, old logs do not need to be kept forever.

If the log directory becomes unnecessarily large, old logs can be archived or removed after determining that they are no longer useful.

---

# 12. Do Not Delete Logs During an Investigation

If something recently went wrong, preserve the relevant logs first.

For example:

```text
Server stopped unexpectedly
        ↓
Do not immediately clean logs
        ↓
Inspect recent logs
        ↓
Identify the cause
        ↓
Archive if necessary
```

Logs can contain the information needed to explain an otherwise mysterious failure.

---

# 13. Windows Maintenance

The Windows host should periodically receive normal Windows updates.

The operating system is part of the server infrastructure.

Keeping Windows updated helps maintain:

* Security
* Hardware compatibility
* Network functionality
* Stability

However, automatic restarts can interrupt the Minecraft server.

Therefore, when possible, schedule major updates/restarts around times when nobody is playing.

---

# 14. Restarting the Server

An occasional restart is not inherently necessary if everything is functioning correctly.

However, restarting can be useful after:

* Windows updates
* Java updates
* Minecraft updates
* Network configuration changes
* Unexpected performance problems

The correct procedure is:

```text
stop
   ↓
Wait for shutdown
   ↓
Perform required maintenance
   ↓
Start server
```

---

# 15. Java Maintenance

The server depends on Java.

Check the installed version with:

```powershell
java -version
```

If Java needs to be upgraded:

1. Stop Minecraft.
2. Back up the world.
3. Install/update Java.
4. Verify:

```powershell
java -version
```

5. Start Minecraft.
6. Check the logs.
7. Test the server.

Never assume a Java update is automatically compatible with every Minecraft server version.

---

# 16. Minecraft Server Updates

Server updates should be handled carefully.

Recommended procedure:

```text
Current Working Server
        │
        ▼
Create Backup
        │
        ▼
Stop Server
        │
        ▼
Replace/Update Server JAR
        │
        ▼
Start Server
        │
        ▼
Check Version
        │
        ▼
Check Logs
        │
        ▼
Test Gameplay
```

If the new version introduces problems, restore the previous working setup and backup.

---

# 17. Do Not Update Just Because an Update Exists

For a private server, stability is often more important than immediately having the newest release.

Before updating, consider:

* Do friends actually need the new version?
* Is the current version stable?
* Does the update require a client update?
* Is the world compatible?
* Is Java compatibility changing?
* Is there a security reason to update immediately?

A working server should not be changed without a reason.

---

# 18. Tailscale Maintenance

Tailscale should also be checked occasionally.

Use:

```powershell
tailscale status
```

This provides a quick view of Tailnet devices.

Check for:

* Unexpected devices
* Offline devices that should be online
* Retired devices
* Duplicate or obsolete machines

The goal is to keep the Tailnet clean.

---

# 19. Tailscale Connectivity Check

If the server has been offline for some time, verify:

```powershell
tailscale ip
```

and:

```powershell
tailscale status
```

If necessary, test connectivity to a friend:

```powershell
tailscale ping <TAILSCALE-IP>
```

This confirms that the networking layer is functioning before attempting Minecraft.

---

# 20. Minecraft Whitelist Maintenance

The whitelist should be reviewed whenever the player group changes.

Useful commands include:

```text
whitelist list
```

```text
whitelist add PlayerName
```

```text
whitelist remove PlayerName
```

Avoid giving server operator permissions merely because someone is on the whitelist.

Being allowed to play and being allowed to administer the server are different privileges.

---

# 21. Server Operator Review

Occasionally check which accounts have elevated permissions.

The principle is simple:

```text
Normal player
     ↓
Normal permissions

Administrator
     ↓
Elevated permissions
```

The number of administrators should be kept small.

The fewer accounts with powerful permissions, the smaller the potential damage from an account compromise or accidental command.

---

# 22. Hardware Monitoring

The laptop is currently the Minecraft host.

Occasionally check:

* CPU usage
* RAM usage
* SSD free space
* System temperature
* Fan behavior
* Network connectivity

The server does not need constant monitoring.

If performance is normal, leave it alone.

---

# 23. Laptop Power Considerations

Because the laptop may remain plugged in while hosting, it is important to consider power behavior.

The server should ideally avoid:

* Unexpected sleep
* Unexpected hibernation
* Battery depletion
* Forced shutdown

For long hosting sessions, appropriate Windows power settings should be used.

However, keeping a laptop awake continuously also has power and thermal implications.

---

# 24. Internet Reliability

The Minecraft server depends on the host's Internet connection for remote players.

If the Internet goes down:

```text
Minecraft
   │
   ▼
Still running locally
   │
   X
   │
Remote players cannot connect
```

Therefore, an Internet outage does not necessarily mean Minecraft itself has crashed.

This distinction is useful when diagnosing downtime.

---

# 25. What to Check After a Power Outage

After an unexpected shutdown:

### 1. Start Windows

### 2. Check Internet

Confirm the laptop has network connectivity.

### 3. Check Tailscale

```powershell
tailscale status
```

### 4. Check Minecraft

Start the server:

```powershell
cd C:\MinecraftServer
java -Xms2G -Xmx4G -jar server.jar nogui
```

### 5. Inspect logs

Look for errors related to the unexpected shutdown.

### 6. Verify the world

Join the server and check that the world appears normal.

---

# 26. Maintenance Before Long Absence

If the host will be unavailable for several days:

1. Stop the server.
2. Create a fresh world backup.
3. Verify the backup exists.
4. Shut down the host safely.

If the server is expected to remain online during the absence, verify:

* Power
* Internet
* Tailscale
* Windows power settings
* Storage
* Backup availability

---

# 27. Recovery Before Major Changes

Before a major change to the host, server software, or configuration:

```text
Stop Minecraft
      │
      ▼
Create a full backup
      │
      ▼
Verify Backup
      │
      ▼
Apply the change
      │
      ▼
Test the server
```

Keep the previous working configuration and a verified backup available until the change has been tested.

If the change causes problems:

```text
Stop the server
      │
      ▼
Restore the previous configuration or backup
      │
      ▼
Start and verify the server
```

This limits downtime and reduces the risk of losing world data.

---

# 28. Recommended Maintenance Schedule

A practical schedule for this small server is:

### Before major changes

**Always**

* Stop server
* Backup world
* Make changes
* Test

### Weekly

Quick check:

* Server starts normally
* Tailscale works
* Storage is healthy
* No obvious errors

### Monthly

Review:

* Backups
* Tailnet devices
* Whitelist
* Operator permissions
* Disk usage
* General server health

### When updating

Always:

* Backup
* Update
* Test
* Keep rollback option

This is more than enough for a small private server.

---

# 29. Maintenance Checklist

## Server

* [ ] Minecraft starts correctly
* [ ] Correct Minecraft version
* [ ] No repeated crash errors
* [ ] World loads correctly

## Network

* [ ] Tailscale running
* [ ] Correct Tailscale IP
* [ ] Friends can connect
* [ ] No unnecessary public exposure

## Security

* [ ] Windows Firewall enabled
* [ ] Tailnet devices reviewed
* [ ] Whitelist reviewed
* [ ] Operator permissions reviewed
* [ ] No credentials committed to GitHub

## Storage

* [ ] Enough free disk space
* [ ] Backups exist
* [ ] Backup can be identified and restored

## System

* [ ] Windows functioning normally
* [ ] Java functioning normally
* [ ] No unexpected shutdowns
* [ ] Laptop is not sleeping unexpectedly

---

# 30. Disaster Recovery

If the server becomes unusable, the recovery process should be:

```text
New/Fixed Host
      │
      ▼
Install Java
      │
      ▼
Install Minecraft Server
      │
      ▼
Configure Tailscale
      │
      ▼
Stop Server
      │
      ▼
Restore World Backup
      │
      ▼
Restore Configuration
      │
      ▼
Start Server
      │
      ▼
Test
```

The important concept is that the server should be **rebuildable**.

A server that only works because of undocumented manual changes is difficult to recover.

The documentation in this repository helps make those procedures repeatable.

---

# 31. Documentation as Maintenance

The repository should document:

* Installation
* Configuration
* Networking
* Security
* Troubleshooting
* Maintenance
* Recovery

This means that months from now, the server does not have to be rebuilt from memory.

The documentation effectively becomes the server's technical manual.

---

# 32. Reliability Priorities

When deciding whether to make a change, prioritize:

```text
1. World safety
2. Security
3. Reliability
4. Compatibility
5. Performance
6. Convenience
```

This ordering is intentional.

For a small private Minecraft server, gaining a tiny performance improvement is not worth risking the world or weakening security.

---

# 33. The Golden Maintenance Rule

The simplest rule for this server is:

> **If the server is working, back it up before changing it.**

And:

> **If something breaks, restore the last known-good state before making the problem more complicated.**

This prevents troubleshooting from turning into configuration chaos.

---

# 34. Final Maintenance Model

The long-term lifecycle is:

```text
                  ┌──────────────┐
                  │    Backup    │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │     Run      │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │     Check    │
                  └──────┬───────┘
                         │
                         ▼
                 Need maintenance?
                    /          \
                  NO            YES
                  │              │
                  │              ▼
                  │           Backup
                  │              │
                  │              ▼
                  │           Change
                  │              │
                  │              ▼
                  │            Test
                  │              │
                  │         ┌────┴────┐
                  │         │         │
                  │      Success   Failure
                  │         │         │
                  │         │         ▼
                  │         │      Restore
                  │         │         │
                  └─────────┴─────────┘
```

The objective is simple:

**Keep the world safe, keep the server reproducible, and never make an irreversible change without a backup.**