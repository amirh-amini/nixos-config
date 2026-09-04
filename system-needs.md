# Personal computer needs worksheet

This document starts from the computer and the person using it—not from an
existing configuration, operating system, package manager, or list of apps.

Its purpose is to discover:

- what the computer must do;
- how it should behave;
- what must be protected or recoverable;
- which conveniences are actually wanted;
- and only later, which tools should provide those capabilities.

Do not try to complete everything at once. Start with the short pass, then open
one detailed section at a time.

## Short pass

These are the decisions that shape almost everything else.

### The person and the machine

- [ ] What is this computer mainly for?
- [ ] Is it personal, professional, shared, or mixed-use?
- [ ] Is it the only computer, or part of a larger setup?
- [ ] What hardware must work reliably?
- [ ] What absolutely cannot be lost?
- [ ] What would make the computer feel pleasant to use every day?

### Core workflows

- [ ] Web browsing
- [ ] Communication
- [ ] Documents and PDFs
- [ ] Notes and knowledge management
- [ ] Media playback or creation
- [ ] Software development
- [ ] Gaming
- [ ] Creative work
- [ ] Research or study
- [ ] Finance or business work
- [ ] Remote access to other machines
- [ ] Specialized hardware or professional software

### Operating priorities

Choose or rank the priorities that matter:

- [ ] Reliability
- [ ] Simplicity
- [ ] Privacy
- [ ] Security
- [ ] Reproducibility
- [ ] Easy experimentation
- [ ] Low maintenance
- [ ] Current software versions
- [ ] Battery life
- [ ] Performance
- [ ] Visual polish
- [ ] Accessibility
- [ ] Compatibility with mainstream software

### Recovery expectations

- [ ] How quickly must the machine recover after a failed update?
- [ ] How quickly must it recover after disk failure, loss, or theft?
- [ ] Which files need backups?
- [ ] Which settings need backups?
- [ ] Which state can be recreated instead of backed up?
- [ ] Is there a tested restore process?

### Management boundary

For every chosen capability, eventually select one:

- [ ] Managed as part of the operating system
- [ ] Installed automatically, configured interactively
- [ ] Managed inside each project or workspace
- [ ] Installed and managed through the application's normal method
- [ ] Deliberately unmanaged or temporary

---

<details>
<summary><strong>1. Hardware and physical machine</strong></summary>

## Hardware and physical machine

### Basic hardware

- [ ] CPU support and firmware
- [ ] Integrated and/or dedicated graphics
- [ ] Internal display
- [ ] External displays
- [ ] Internal keyboard
- [ ] Touchpad, trackpoint, or touchscreen
- [ ] Mouse or other pointing devices
- [ ] Speakers and headphone output
- [ ] Microphone
- [ ] Webcam
- [ ] Storage devices
- [ ] Battery and charging
- [ ] Temperature and fan behavior

### Connectivity

- [ ] Wi-Fi
- [ ] Ethernet
- [ ] Bluetooth
- [ ] Mobile broadband
- [ ] VPN
- [ ] USB and Thunderbolt devices
- [ ] Docks
- [ ] Printers and scanners
- [ ] External audio devices
- [ ] Game controllers
- [ ] Drawing tablets
- [ ] Smart cards or security keys

### Hardware behavior

- [ ] Preferred behavior on battery
- [ ] Preferred behavior while plugged in
- [ ] Charging limits
- [ ] Suspend behavior
- [ ] Hibernate behavior
- [ ] Lid-close behavior
- [ ] Thermal and fan priorities
- [ ] Dedicated-GPU policy: always on, automatic, or on demand
- [ ] External-monitor layouts
- [ ] Display scaling, refresh rate, brightness, and color temperature

### Questions

- What hardware failures or quirks already exist?
- Which peripherals are used frequently enough to configure explicitly?
- Which behavior should be automatic, and which should stay manual?

</details>

<details>
<summary><strong>2. Boot, disks, filesystems, and recovery</strong></summary>

## Boot, disks, filesystems, and recovery

### Boot

- [ ] Firmware and bootloader choice
- [ ] Disk encryption before login
- [ ] Secure Boot
- [ ] Multiple operating systems
- [ ] Recovery or rescue entry
- [ ] Number of old system generations retained
- [ ] Acceptable boot-menu delay

### Storage layout

- [ ] Filesystem choice
- [ ] Partition or volume layout
- [ ] Swap or compressed RAM swap
- [ ] Separate areas for system, user data, logs, and temporary data
- [ ] Compression
- [ ] SSD trimming
- [ ] Filesystem integrity checks
- [ ] Disk-health monitoring
- [ ] Support for external filesystem formats

### Local recovery

- [ ] System rollback after a bad update
- [ ] File snapshots for accidental deletion or modification
- [ ] Snapshot retention policy
- [ ] Recovery environment or bootable installer
- [ ] Written recovery steps available without the affected computer

### Backups

- [ ] Files included and excluded
- [ ] Local backup destination
- [ ] Off-site or cloud backup destination
- [ ] Encryption
- [ ] Schedule
- [ ] Retention
- [ ] Version history
- [ ] Restore testing
- [ ] Recovery plan after theft or total disk failure

### Questions

- Is rollback being confused with backup?
- Can important files be restored without remembering special commands?
- Are credentials and encryption keys recoverable if the laptop is lost?

</details>

<details>
<summary><strong>3. Identity, login, secrets, and security</strong></summary>

## Identity, login, secrets, and security

### Local identity

- [ ] User accounts
- [ ] Administrator access
- [ ] Shared or guest access
- [ ] Login method
- [ ] Screen locking
- [ ] Automatic login policy
- [ ] Fingerprint, face, password, PIN, or hardware-key authentication

### Secrets and credentials

- [ ] Password manager
- [ ] SSH keys
- [ ] GPG or signing keys
- [ ] API keys
- [ ] Wi-Fi and VPN credentials
- [ ] Browser-stored credentials
- [ ] Recovery codes
- [ ] Secret backup and recovery
- [ ] Separation of personal and work credentials

### System security

- [ ] Firewall
- [ ] Full-disk encryption
- [ ] Secure Boot
- [ ] Mandatory access control or application sandboxing
- [ ] Restricted administrator commands
- [ ] Automatic or deliberate security updates
- [ ] Vulnerability and end-of-life software policy
- [ ] Untrusted USB-device policy
- [ ] Remote-login policy
- [ ] Lost-device response

### Privacy

- [ ] Diagnostic and telemetry policy
- [ ] Location access
- [ ] Camera and microphone access
- [ ] Clipboard exposure
- [ ] Browser tracking protection
- [ ] Search provider
- [ ] DNS provider or filtering
- [ ] Local versus cloud processing
- [ ] Data retained by AI tools

### Questions

- What is the realistic threat model?
- Which protections would create more friction than value?
- Which secrets currently depend on one device or one person's memory?

</details>

<details>
<summary><strong>4. Network, sharing, and remote access</strong></summary>

## Network, sharing, and remote access

### Everyday networking

- [ ] Wi-Fi management
- [ ] Ethernet
- [ ] DNS behavior
- [ ] VPN profiles
- [ ] Captive portals
- [ ] Network time synchronization
- [ ] Metered-network behavior

### Sharing and discovery

- [ ] File sharing with other computers
- [ ] Phone integration
- [ ] Printer discovery
- [ ] Media-device discovery
- [ ] Local service discovery
- [ ] Screen casting
- [ ] Bluetooth file transfer

### Remote access

- [ ] SSH client
- [ ] SSH server
- [ ] Remote desktop client
- [ ] Remote desktop server
- [ ] Private network or mesh VPN
- [ ] Wake-on-LAN
- [ ] Remote backups
- [ ] Access policy for services running on the laptop

### Questions

- Which services must remain local-only?
- Does anything need to be reachable while away from home?
- Are network services visible only when they need to be?

</details>

<details>
<summary><strong>5. Desktop interaction and accessibility</strong></summary>

## Desktop interaction and accessibility

### Session and navigation

- [ ] Graphical login experience
- [ ] Desktop environment or window manager
- [ ] Keyboard-driven versus pointer-driven workflow
- [ ] Application launcher
- [ ] Window switching
- [ ] Workspace behavior
- [ ] Multi-monitor behavior
- [ ] System tray
- [ ] Status bar or panel
- [ ] Logout and power menu

### Input

- [ ] Keyboard layouts and switching
- [ ] Key remapping
- [ ] Global shortcuts
- [ ] Touchpad gestures
- [ ] Mouse acceleration and sensitivity
- [ ] Pointer theme and size
- [ ] Voice input
- [ ] On-screen keyboard

### Feedback and interruptions

- [ ] Notifications
- [ ] Do-not-disturb behavior
- [ ] Volume and brightness display
- [ ] Battery warnings
- [ ] Error reporting
- [ ] Clipboard history
- [ ] Screenshot and screen-recording workflow

### Appearance

- [ ] Light or dark appearance
- [ ] Fonts
- [ ] Icons
- [ ] Cursor
- [ ] Wallpaper
- [ ] Application consistency
- [ ] Animation and transparency preferences
- [ ] Color management

### Accessibility

- [ ] Text scaling
- [ ] High contrast
- [ ] Reduced motion
- [ ] Screen reader
- [ ] Magnifier
- [ ] Color-vision accommodations
- [ ] Sticky, slow, bounce, or mouse keys
- [ ] Captions and audio accessibility
- [ ] Voice control or dictation

### Idle and power behavior

- [ ] Screen dim timeout
- [ ] Lock timeout
- [ ] Display-off timeout
- [ ] Suspend timeout
- [ ] Behavior during media playback, presentations, and long-running tasks

### Questions

- Which repeated actions currently feel annoying?
- Which information needs to remain visible all the time?
- Which visual customization is useful rather than maintenance work?

</details>

<details>
<summary><strong>6. Files, search, documents, and personal information</strong></summary>

## Files, search, documents, and personal information

### File handling

- [ ] Graphical file manager
- [ ] Terminal file manager
- [ ] Archive creation and extraction
- [ ] Trash and recovery
- [ ] File previews
- [ ] Metadata and EXIF inspection
- [ ] Duplicate-file discovery
- [ ] External-drive mounting
- [ ] Phone and remote-filesystem access

### Finding information

- [ ] File-name search
- [ ] File-content search
- [ ] Desktop-wide indexing
- [ ] Recent-file history
- [ ] Bookmarks and quick locations
- [ ] Search inside PDFs and documents
- [ ] Search across notes

### Documents

- [ ] Plain-text editor
- [ ] Office documents
- [ ] PDF reading
- [ ] PDF annotation
- [ ] PDF manipulation
- [ ] Scanning and OCR
- [ ] Printing
- [ ] E-books
- [ ] Spreadsheets
- [ ] Presentations

### Notes and knowledge

- [ ] Quick scratchpad
- [ ] Long-lived notes
- [ ] Tasks and reminders
- [ ] Calendar
- [ ] Personal wiki or knowledge graph
- [ ] Web clipping
- [ ] Handwritten notes
- [ ] Sync across devices
- [ ] Export and data portability
- [ ] Local-only versus cloud storage

### Questions

- Where should a new file or note go by default?
- Which information must be usable without internet access?
- Can important data be exported in a normal, durable format?

</details>

<details>
<summary><strong>7. Web, communication, and online accounts</strong></summary>

## Web, communication, and online accounts

### Browsing

- [ ] Primary browser
- [ ] Backup or compatibility browser
- [ ] Separate work/personal profiles
- [ ] Password and bookmark synchronization
- [ ] Ad and tracker blocking
- [ ] Cookie policy
- [ ] JavaScript and site-permission policy
- [ ] Downloads behavior
- [ ] PDF behavior
- [ ] Media/DRM support
- [ ] Browser extensions
- [ ] Default browser and URL handlers

### Communication

- [ ] Email
- [ ] Calendar and invitations
- [ ] Team chat
- [ ] Personal messaging
- [ ] Voice and video calls
- [ ] SMS or phone integration
- [ ] Social platforms
- [ ] Multiple-account handling
- [ ] Notification policy

### Online accounts

- [ ] Account inventory
- [ ] Multi-factor authentication
- [ ] Recovery methods
- [ ] Work/personal separation
- [ ] Single sign-on requirements
- [ ] Files and data stored by each service

### Questions

- Is each additional client solving a distinct problem?
- Which services need native applications rather than a browser?
- Which accounts or profiles must never mix?

</details>

<details>
<summary><strong>8. Audio, video, images, and creative work</strong></summary>

## Audio, video, images, and creative work

### Playback

- [ ] Music playback
- [ ] Local video playback
- [ ] Streaming services
- [ ] Podcasts
- [ ] Online-video downloading
- [ ] Subtitle support
- [ ] Hardware decoding
- [ ] Media-key integration
- [ ] Playback history and resume behavior

### Capture

- [ ] Screenshots
- [ ] Screen recording
- [ ] Microphone recording
- [ ] Webcam capture
- [ ] Streaming
- [ ] Virtual camera
- [ ] Scanning

### Creation and editing

- [ ] Image viewing
- [ ] Image editing
- [ ] Photography and RAW processing
- [ ] Vector graphics
- [ ] Audio editing
- [ ] Video editing
- [ ] 3D work
- [ ] Drawing or painting
- [ ] Color management

### Questions

- Is media consumption local, streamed, or both?
- Which formats and hardware acceleration must work?
- Is professional color/audio behavior required?

</details>

<details>
<summary><strong>9. Software development and technical work</strong></summary>

## Software development and technical work

### General workflow

- [ ] Shell
- [ ] Terminal emulator
- [ ] Terminal multiplexer
- [ ] Version control
- [ ] Repository hosting tools
- [ ] Text search and file navigation
- [ ] Editor or IDE
- [ ] Containers or virtual machines
- [ ] Database clients
- [ ] API clients
- [ ] Documentation tools
- [ ] Debugging and profiling

### Languages and projects

- [ ] Languages actively used
- [ ] Compiler or interpreter versions
- [ ] Package managers
- [ ] Language servers
- [ ] Formatters
- [ ] Linters
- [ ] Test runners
- [ ] Build systems
- [ ] Pre-commit checks
- [ ] Project templates
- [ ] Local services required during development

### Environment boundary

For each tool, decide whether it is:

- [ ] Needed on every machine/login
- [ ] Shared by many projects
- [ ] Specific to one project
- [ ] Needed only by an editor
- [ ] Temporary for an experiment

### Reproducibility and compatibility

- [ ] Per-project development environments
- [ ] Locked dependencies
- [ ] Support for ordinary dynamically linked Linux binaries
- [ ] Proprietary SDKs or tools
- [ ] GPU/CUDA development
- [ ] Cross-compilation
- [ ] Remote development

### Questions

- Can a project explain and create its own environment?
- Are global tools truly global, or merely left over from old projects?
- Does declarative configuration improve the workflow or slow iteration down?

</details>

<details>
<summary><strong>10. AI-assisted work and local models</strong></summary>

## AI-assisted work and local models

### Uses

- [ ] General chat and research
- [ ] Coding assistance
- [ ] Editor completion
- [ ] Agentic repository work
- [ ] Voice transcription
- [ ] Image generation
- [ ] Document analysis
- [ ] Local/offline inference
- [ ] Automation and orchestration

### Interfaces

- [ ] Web application
- [ ] Desktop application
- [ ] Command-line tool
- [ ] Editor extension
- [ ] Local API
- [ ] Background service
- [ ] Multiple-agent session manager
- [ ] Usage and cost reporting

### Models and data

- [ ] Cloud providers
- [ ] Local model runner
- [ ] GPU acceleration
- [ ] Model storage location
- [ ] Model download/update method
- [ ] API-key handling
- [ ] Conversation and code retention policy
- [ ] Telemetry policy
- [ ] Separation of private and shareable data

### Tool selection

- [ ] Primary tool for each actual workflow
- [ ] Backup tool, if necessary
- [ ] Experimental tools with an expiration/review date
- [ ] Stable versus preview/nightly channels
- [ ] Update frequency
- [ ] Cost of custom packaging and maintenance

### Questions

- Which tools solve distinct jobs, and which are duplicates?
- Which tools need to update faster than the operating-system configuration?
- What data is sent externally, and is that acceptable?
- Should downloaded models and agent state survive a system rebuild?

</details>

<details>
<summary><strong>11. Gaming, virtualization, and compatibility</strong></summary>

## Gaming, virtualization, and compatibility

### Gaming

- [ ] Native games
- [ ] Steam or other stores
- [ ] Windows compatibility layer
- [ ] Game controllers
- [ ] Performance overlays
- [ ] Game recording or streaming
- [ ] Dedicated-GPU launch behavior
- [ ] Mod management

### Virtualization and containers

- [ ] Containers for development
- [ ] System containers
- [ ] Virtual machines
- [ ] Windows virtual machine
- [ ] Android environment
- [ ] Rootless versus privileged containers
- [ ] GPU access inside containers or virtual machines
- [ ] Networking and storage policy

### Compatibility

- [ ] Proprietary applications
- [ ] AppImage
- [ ] Flatpak
- [ ] Ordinary Linux binaries
- [ ] Windows applications
- [ ] Android applications
- [ ] Web application substitutes

### Questions

- Is compatibility needed regularly or only occasionally?
- Would a sandboxed packaging format reduce configuration maintenance?
- Which compatibility layers increase the machine's security exposure?

</details>

<details>
<summary><strong>12. Automation, maintenance, and observability</strong></summary>

## Automation, maintenance, and observability

### Updates

- [ ] Operating-system update schedule
- [ ] Application update schedule
- [ ] Firmware updates
- [ ] Browser and security-critical update urgency
- [ ] Manual approval versus automation
- [ ] Preview of changes before applying
- [ ] Rollback after failure

### Cleanup

- [ ] Old system generations
- [ ] Package/build cache
- [ ] Temporary files
- [ ] Logs
- [ ] Browser caches
- [ ] Container images and volumes
- [ ] Downloaded development dependencies
- [ ] Old local AI models

### Monitoring

- [ ] CPU, memory, temperature, disk, GPU, and battery visibility
- [ ] Disk-health warnings
- [ ] Low-space warnings
- [ ] Failed-service visibility
- [ ] Backup failure alerts
- [ ] Battery-health tracking
- [ ] Network-usage visibility

### Automation

- [ ] Scheduled jobs
- [ ] Repeated personal tasks
- [ ] File synchronization
- [ ] Backup jobs
- [ ] Development scripts
- [ ] Laptop docking/undocking behavior
- [ ] Network-dependent behavior

### Questions

- What maintenance is currently forgotten until something breaks?
- Which automation failures need visible notification?
- Can maintenance be performed with a few memorable commands?

</details>

<details>
<summary><strong>13. Configuration ownership and repository design</strong></summary>

## Configuration ownership and repository design

Only answer this after identifying the desired system behavior.

### For each capability

- [ ] What outcome is required?
- [ ] What tool provides it?
- [ ] Is the tool essential, optional, experimental, or temporary?
- [ ] Who should own installation?
- [ ] Who should own configuration?
- [ ] Who should own mutable data and state?
- [ ] How should it update?
- [ ] How should it be tested?
- [ ] How should it be removed?

### Possible owners

- [ ] Operating-system configuration
- [ ] User-environment configuration
- [ ] Application's native configuration/UI
- [ ] Individual project repository
- [ ] Container or virtual machine
- [ ] Manual installation
- [ ] External service

### Repository qualities

- [ ] One obvious command to validate changes
- [ ] One obvious command to apply changes
- [ ] Safe rollback
- [ ] Machine-specific facts clearly identifiable
- [ ] Secrets excluded
- [ ] Generated files identifiable
- [ ] Custom packages independently buildable
- [ ] External inputs pinned where useful
- [ ] Updates understandable and reviewable
- [ ] Comments explain non-obvious reasons, not temporary opinions
- [ ] Experimental choices easy to remove
- [ ] No abstraction without a current practical use

### Questions

- Does declaring this item save effort over time?
- Does it make recovery meaningfully easier?
- Does it prevent useful interactive configuration?
- Will it require frequent compatibility fixes?
- Can the native application format be tracked directly instead?
- Is this configuration shared, or is abstraction being added for an imaginary
  future need?

</details>

## How to use the completed worksheet

Once a section has answers:

1. Write the desired outcome without naming a tool.
2. List the minimum capabilities needed for that outcome.
3. Compare tools only if a choice is genuinely open.
4. Select the tool.
5. Select its configuration owner and update method.
6. Implement and verify that one area.
7. Remove alternatives that no longer have a defined purpose.

The resulting repository structure should follow those real ownership and
maintenance decisions. It should not be designed before them.
