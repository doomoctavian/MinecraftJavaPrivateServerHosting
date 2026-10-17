# Minecraft Server Troubleshooting

This document provides a systematic troubleshooting procedure for the Minecraft server.

The most important principle is:

> **Do not randomly change settings until something works. Identify which layer is failing first.**

The server consists of several independent layers:

```text
Minecraft
   ↓
Java
   ↓
Windows
   ↓
Windows Firewall
   ↓
Tailscale
   ↓
Network
```

A problem at any one of these layers can appear to the user as simply:

> "Minecraft isn't connecting."

---

# 1. Troubleshooting Philosophy

When something stops working, troubleshoot from the bottom up.

Recommended order:

```text
1. Is the computer running?
        ↓
2. Is Java working?
        ↓
3. Is Minecraft running?
        ↓
4. Is Tailscale running?
        ↓
5. Can the devices communicate through Tailscale?
        ↓
6. Is Minecraft listening on port 25565?
        ↓
7. Is Windows Firewall allowing the connection?
        ↓
8. Is the player authorized?
```

This prevents unrelated settings from being changed unnecessarily.

---

# 2. Server Does Not Start

## Symptoms

Possible symptoms include:

* PowerShell immediately returns to the prompt.
* Java reports an error.
* Minecraft stops during startup.
* The server repeatedly crashes.

---

## Step 1 — Check Java

Run:

```powershell
java -version
```

If Windows says:

```text
'java' is not recognized...
```

Java is either not installed or is not correctly configured in the system PATH.

---

## Step 2 — Check the Server Directory

Navigate to:

```powershell
cd C:\MinecraftServer
```

Then check that the server JAR exists.

The expected file is:

```text
server.jar
```

---

## Step 3 — Start Manually

Run:

```powershell
java -Xms2G -Xmx4G -jar server.jar nogui
```

Read the error message instead of immediately restarting.

The error usually provides the first clue about the failure.

---

# 3. EULA Error

If the server reports that the EULA has not been accepted:

Open:

```text
C:\MinecraftServer\eula.txt
```

Change:

```text
eula=false
```

to:

```text
eula=true
```

Save the file and restart the server.

---

# 4. Wrong Minecraft Version

One problem encountered during setup was version confusion.

The final working server was confirmed as:

```text
Minecraft 26.3
```

The startup log contained:

```text
Starting minecraft server version 26.3
```

If the client and server versions do not match appropriately, players may receive version-related connection errors.

Always check the startup log instead of assuming which version is installed.

---

# 5. Server Starts but Friends Cannot Connect

This is the most important troubleshooting case.

Do **not** immediately change Minecraft settings.

Work through the following layers.

---

## Step 1 — Confirm Minecraft Is Running

Look at the server console.

The server should be fully started rather than still generating the world or loading.

If the console is running normally, continue.

---

## Step 2 — Check Tailscale

Run:

```powershell
tailscale status
```

The Windows host should appear as an active Tailscale device.

The server's Tailscale address is:

```text
100.118.69.26
```

---

## Step 3 — Check the Friend's Tailscale Status

The friend must also be connected to the same appropriate Tailnet.

If their Tailscale client is offline, Minecraft cannot reach the server through Tailscale.

---

# 6. Test Tailscale Before Minecraft

This is one of the most important troubleshooting rules.

Run:

```powershell
tailscale ping <TAILSCALE-IP>
```

For example:

```powershell
tailscale ping 100.71.255.70
```

If this fails, investigate Tailscale first.

Do not start changing Minecraft configuration.

---

# 7. Tailscale Ping Timeout

During testing, a Tailscale ping produced repeated:

```text
ping "100.71.255.70" timed out
```

This demonstrated an important distinction:

> A Minecraft connection problem can actually be a Tailscale connectivity problem.

Possible causes include:

* The destination computer is offline.
* Tailscale is not running on the destination.
* The device has lost Internet connectivity.
* The device is logged out.
* Tailnet access has changed.
* A firewall or network condition is interfering.
* The device is asleep or otherwise unreachable.

---

# 8. Check Whether the Destination Device Is Online

Run:

```powershell
tailscale status
```

Look for the target device.

For example:

```text
100.71.255.70
```

If the device is shown as offline, a timeout is expected.

The solution is not to modify Minecraft.

The destination device needs to reconnect to Tailscale.

---

# 9. Check Tailscale IP

On the Minecraft host:

```powershell
tailscale ip
```

The server should report its Tailscale address.

The current server address is:

```text
100.118.69.26
```

If no Tailscale address is returned, Tailscale itself needs to be fixed first.

---

# 10. Minecraft Server Running but Port Unreachable

If:

```text
Minecraft = running
Tailscale = running
Tailscale connectivity = working
```

but Minecraft still cannot connect, check whether Minecraft is actually listening on port `25565`.

Windows can be queried with:

```powershell
netstat -ano | findstr :25565
```

A listening service should appear.

The exact output can vary depending on the Java/network configuration.

The important question is:

> Is something actually listening on port 25565?

---

# 11. Firewall Problems

If Tailscale connectivity works but Minecraft does not, Windows Firewall becomes a likely candidate.

Do not immediately disable the firewall.

Instead:

1. Identify the required traffic.
2. Check the firewall rules.
3. Allow only what is necessary.
4. Test again.

The goal is:

```text
Minimum required access
        +
Firewall enabled
```

rather than:

```text
Firewall disabled
```

---

# 12. Friend Uses the Wrong IP

The server has multiple network addresses.

For example:

```text
LAN:
192.168.1.73
```

and:

```text
Tailscale:
100.118.69.26
```

A remote friend using Tailscale should normally use:

```text
100.118.69.26:25565
```

not:

```text
192.168.1.73:25565
```

The LAN address is only appropriate when the devices are on the same local network or otherwise have a route to that private network.

---

# 13. Friend Can Ping Tailscale but Minecraft Still Fails

This is an important intermediate state.

If:

```text
Tailscale connectivity = OK
```

but:

```text
Minecraft = unreachable
```

then the problem has moved above the Tailscale layer.

Check:

```text
1. Minecraft is running
2. Minecraft is listening on 25565
3. Windows Firewall
4. server.properties
5. Client/server version compatibility
6. Minecraft account/whitelist
```

---

# 14. Whitelist Problems

If the player can reach the server but Minecraft says they are not allowed to join, check:

```text
whitelist list
```

Add them with:

```text
whitelist add PlayerName
```

Make sure the player is using the correct Minecraft account.

If necessary, remove and re-add the player:

```text
whitelist remove PlayerName
whitelist add PlayerName
```

---

# 15. Player Changed Username

If a friend changed their Minecraft username and suddenly cannot join, the whitelist should be checked.

Do not assume the old visible name is still correct.

Check:

```text
whitelist list
```

Then update the whitelist if necessary.

---

# 16. Server Suddenly Stops Working

If the server previously worked and suddenly does not, check the following in order:

```text
1. Is the laptop powered on?
2. Is Windows running?
3. Is Java running?
4. Is Minecraft running?
5. Is Tailscale running?
6. Is the laptop connected to the Internet?
7. Is the Tailnet accessible?
8. Is the Minecraft port listening?
9. Did Windows restart?
10. Did Minecraft or Java update?
```

A server that was working yesterday can fail today simply because the host was restarted and the Minecraft process was not started again.

---

# 17. Windows Restarted

If Windows updates or another event causes the laptop to restart, the Minecraft server process may no longer be running.

Check:

```powershell
cd C:\MinecraftServer
```

Then restart:

```powershell
java -Xms2G -Xmx4G -jar server.jar nogui
```

Also verify:

```powershell
tailscale status
```

---

# 18. Laptop Goes to Sleep

A laptop cannot reliably act as a server if it enters sleep mode.

Symptoms can include:

* Friends suddenly disconnect.
* Tailscale becomes unreachable.
* Minecraft becomes unreachable.
* The host appears offline.

If the laptop is intended to remain a server for long periods, Windows power settings should be configured appropriately.

However, sleep settings should be changed deliberately because preventing sleep increases power consumption.

---

# 19. Internet Connection Failure

Tailscale still requires network connectivity.

If the host loses Internet access:

```text
Minecraft
   │
   ▼
Running locally
   │
   X
   │
Internet/Tailscale unavailable
```

The server may appear perfectly healthy on the laptop while remote players cannot connect.

This is why:

> "Minecraft is running" does not necessarily mean "Minecraft is reachable."

---

# 20. High Lag

If players can connect but experience lag, identify whether the problem is:

* Server performance
* Host CPU usage
* RAM pressure
* Network latency
* Tailscale relay
* Internet connection
* Excessive world activity

First check the host's resource usage.

The server was configured with:

```text
-Xms2G
-Xmx4G
```

For 4–6 players on Vanilla Minecraft, this is a reasonable starting point.

Increasing RAM indefinitely is not a universal solution.

---

# 21. Tailscale Relay vs Direct Connection

If the connection feels unusually slow, check whether Tailscale is using a direct connection or a relay.

A direct connection is generally preferable.

Conceptually:

```text
Direct:

Friend ───────── Server
```

versus:

```text
Relay:

Friend ─── Relay ─── Server
```

A relay can introduce additional latency.

However, a relay connection is still potentially usable for a small Minecraft server.

---

# 22. High CPU Usage

If the server causes unusually high CPU usage:

Check:

* Number of players
* Render/view distance
* Simulation distance
* Large farms
* Redstone machines
* Entity counts
* Chunk generation
* Other applications running on Windows

Do not assume the Minecraft server itself is always responsible.

The laptop may also be running browsers, IDEs, updates, or other applications.

---

# 23. High RAM Usage

The server's JVM maximum is:

```text
4 GB
```

This does not mean Minecraft will always consume exactly 4 GB.

The JVM can use memory dynamically.

If the entire Windows system is running low on memory, check what other applications are using RAM.

The machine has:

```text
16 GB RAM
```

so allocating 4 GB to Minecraft leaves substantial memory for Windows and other processes.

---

# 24. World Corruption or Unexpected Shutdown

If Minecraft crashes or the machine loses power while the world is being written, there is a possibility of corruption.

First:

```text
Do not repeatedly restart and modify the world.
```

Instead:

1. Stop the server if it is still running.
2. Make a copy of the current world.
3. Preserve logs.
4. Identify the cause.
5. Restore a known-good backup if necessary.

Never experiment directly on the only copy of an important world.

---

# 25. Server Crashes

Check the relevant logs.

Minecraft typically generates runtime information in:

```text
logs/
```

Crash information may also be stored under:

```text
crash-reports/
```

Look for:

* Java errors
* Out-of-memory errors
* Server exceptions
* World/chunk errors
* Version incompatibilities

The first error in a crash report is often more useful than the final error message.

---

# 26. Do Not Delete Files Randomly

A common troubleshooting mistake is:

> "This file looks unnecessary, so I'll delete it."

Avoid this.

Minecraft generates many files that may look unfamiliar.

Before deleting anything:

1. Identify what the file does.
2. Back it up.
3. Determine whether Minecraft regenerates it.
4. Only then modify or remove it.

This is particularly important for world data.

---

# 27. Server Doesn't Shut Down Correctly

Use:

```text
stop
```

from the Minecraft console.

Wait until the server finishes saving and exits.

If the process appears frozen, investigate before force-killing it.

Repeated forced shutdowns increase the risk of data loss.

---

# 28. Tailscale Works but Friend Still Cannot Join

Use this decision tree:

```text
Can friend reach the host through Tailscale?
              │
        ┌─────┴─────┐
        │            │
       NO           YES
        │            │
   Fix Tailscale     ▼
                  Can Minecraft
                  port be reached?
                       │
                 ┌─────┴─────┐
                 │           │
                NO          YES
                 │           │
             Firewall/      ▼
             Minecraft    Is player
             listening?   authorized?
                              │
                        ┌─────┴─────┐
                        │           │
                       NO          YES
                        │           │
                   Whitelist/   Investigate
                   account      client/server
                                compatibility
```

This is much more efficient than randomly changing settings.

---

# 29. Complete Diagnostic Command Set

### Java

```powershell
java -version
```

### Enter server directory

```powershell
cd C:\MinecraftServer
```

### Start server

```powershell
java -Xms2G -Xmx4G -jar server.jar nogui
```

### Tailscale status

```powershell
tailscale status
```

### Tailscale IP

```powershell
tailscale ip
```

### Test another Tailnet device

```powershell
tailscale ping <TAILSCALE-IP>
```

### Check Minecraft port

```powershell
netstat -ano | findstr :25565
```

These commands provide a useful first-line diagnostic toolkit.

---

# 30. The Golden Troubleshooting Rule

When something fails, ask:

> **Which layer failed?**

For example:

### Case A

```text
Minecraft ❌
Tailscale ❌
```

Fix Tailscale first.

### Case B

```text
Minecraft ❌
Tailscale ✅
```

Investigate Minecraft, firewall, or port configuration.

### Case C

```text
Minecraft ✅
Tailscale ✅
Player ❌
```

Investigate whitelist/account/version issues.

### Case D

```text
Everyone experiences lag
```

Investigate server performance and networking.

### Case E

```text
Only one friend experiences problems
```

Investigate that friend's device, Tailscale connection, Minecraft client, or account.

This classification dramatically reduces troubleshooting time.

---

# 31. Quick Emergency Checklist

If friends suddenly say:

> "The server is down."

Run:

```powershell
tailscale status
```

Then verify the Minecraft console.

Then:

```powershell
tailscale ip
```

Then check:

```powershell
netstat -ano | findstr :25565
```

Then ask one friend to test:

```powershell
tailscale ping 100.118.69.26
```

If Tailscale works but Minecraft does not, investigate the Minecraft service rather than the Tailnet.

---

# 32. Final Troubleshooting Flow

The entire diagnostic process can be represented as:

```text
                FRIEND CANNOT JOIN
                        │
                        ▼
                Is host powered on?
                   /          \
                 NO            YES
                 │              │
              Power on          ▼
                          Is Tailscale online?
                             /        \
                           NO          YES
                           │            │
                      Fix Tailscale    ▼
                                Can Tailnet reach host?
                                  /          \
                                NO            YES
                                │              │
                           Fix network         ▼
                                      Is Minecraft running?
                                        /          \
                                      NO            YES
                                      │              │
                                   Start it         ▼
                                             Is port 25565
                                              listening?
                                               /      \
                                             NO        YES
                                             │          │
                                        Fix server/     ▼
                                        firewall   Is player allowed?
                                                     /       \
                                                   NO         YES
                                                   │           │
                                              Whitelist    Check client,
                                              /account      version,
                                                           performance
```

---

# 33. Lessons From the Actual Deployment

**Network troubleshooting must be separated from Minecraft troubleshooting.**

The Tailscale timeout experienced during testing demonstrated this clearly.

The command:

```powershell
tailscale ping 100.71.255.70
```

timed out repeatedly.

That did not automatically mean Minecraft was broken.

The correct conclusion was:

```text
Tailscale connectivity needs investigation.
```

This is the kind of distinction that prevents hours of unnecessary configuration changes.

---

The goal of troubleshooting is not simply to make the server work again.

It is to understand **why it stopped working**, fix the correct component, and avoid creating a new problem while fixing the old one.