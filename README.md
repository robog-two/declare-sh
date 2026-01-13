# `declare.sh`
Use a declarative style to manage your infrastructure as code, all with bash scripts and bare-metal Debian.

*Probably don't use this in production. If you do, let me know if you run into any problems or see any flaws. My issues are open, as always.*

*Claude Code was used to assist in the creation of this project. See [my stance on using Generative AI in my work](https://robog.net/docs/generative-ai-usage/).*

## Install

1. Fork this repository to its own "machine" repository. This will be where you store the declarative configuration for the machine.
2. Configure that repository to send a GitHub webhook to http://your.server.net:23614/webhook (recommended but not required, the server will check every 24h for new commits)
3. Set up a Debian machine to your ideal "blank" configuration. You should use the same setup on all machines, ideally. You will need btrfs on `/`, and you should make a separate persistent partition, you might want it later.
3. Run the below command, replace `<repo>` with the HTTPS git URL of your repo

```bash
curl -fsSL https://sh.robog.net/declare | bash -s -- <repo>
```

## Why

I've been working on my homelab setup lately after some poorly executed upgrades broke SSH on my machines. Having worked with AWS and "infrastructure as code," I wondered if there was a way to do this on my own machines. I found Ansible a little too finicky and NixOS is a little too bespoke, so I wondered if there was a way to make a declarative system that used good old bash running on old reliable Debian. I used Claude Code to throw together a quick prototype of my vision, leveraging `btrfs` to do a system restore and `systemd` to run some special init scripts. 
