#!/usr/bin/env sh
# 
# From time to time an update of ArchLinux mess up with my laptop sound.
# This script stop the wireplumber session, remove its configuration and
# start wireplumber again, redoing the configuration.
#
# @author: Navaror-Torres, Agustin
# @date: 2026-01-15
# @version: 0.1
#

systemctl --user stop wireplumber
rm -r ~/.local/state/wireplumber
systemctl --user start wireplumber
