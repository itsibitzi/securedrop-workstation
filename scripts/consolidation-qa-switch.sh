#!/usr/bin/bash

#
# Updates pre-consolidation templates and dom0 to use QA repos.
#
# As root, untar the archive containing this script in /srv/salt, then run the script.
#

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

cp -R `dirname "$0"`/qa-switch/ /srv/salt/

cd /srv/salt
echo Updating dom0...
qubesctl --show-output --targets dom0 state.apply qa-switch.dom0

export template_list="sd-app-buster-template sd-devices-buster-template sd-log-buster-template sd-proxy-buster-template sd-viewer-buster-template securedrop-workstation-buster whonix-gw-15"

echo Updating Debian-based templates:
for t in $template_list; do echo Updating $t...; qubesctl --show-output --skip-dom0 --targets $t state.apply switch.buster; done

echo Replacing prod config YAML...

if [ ! -f "/srv/salt/qa-switcher/sd-default-config.yml.orig" ]; then
  cp sd-default-config.yml qa-switch/sd-default-config.yml.orig
fi 
cp qa-switch/sd-qa-config.yml sd-default-config.yml

echo Done! Next, run the updater.
