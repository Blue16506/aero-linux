#!/bin/bash
# Automatically run by archiso on boot

# Auto-launch aero-install on boot if desired
if tty -s; then
    /usr/local/bin/aero-install
fi
