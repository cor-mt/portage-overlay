My presonal Gentoo/Funtoo Portage overlay
=========================================

My personal portage playground. I thought others might benefit from my set of ebuilds, so here they are. Be aware that it may be full of bugs ;)

Installing the overlay
======================

You will need to install layman according to the Gentoo Overlay Guide

https://wiki.gentoo.org/wiki/Project:Overlays/User_Guide

After having layman installed edit its configuration in /etc/layman/layman.cfg to add this overlay to it's list of known overlays.


    overlays  : http://www.gentoo.org/proj/en/overlays/repositories.xml
                https://raw.github.com/cor-mt/portage-overlay/master/overlay.xml

Next sync layman and add the gnome15 overlay

    layman -S
    layman -a corl
