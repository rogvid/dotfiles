# Set up Kanata

## Ubuntu

After running the stow command or `setup.sh` script, you'll need to reload the service daemon like this:

```bash
systemctl --user daemon-reload
systemctl --user enable kanata.service
systemctl --user start kanata.service
systemctl --user status kanata.service   # check whether the service is running
```
