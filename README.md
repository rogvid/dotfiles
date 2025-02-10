# My Dotfiles

This repository contains the configurations for tools that I use on a daily basis. I use this dotfiles repository in combination with my ansible zero-touch provisioning.

## Requirements

Before setting up a new dev environment make sure the following is present:

- `git`
- `curl`

# Instructions for quickly setting up configurations on a new machine

The recommended setup is to run the init script from git:

```bash
curl -Lks github.com/rogvid/dotfiles/setup.sh | /bin/bash
```
