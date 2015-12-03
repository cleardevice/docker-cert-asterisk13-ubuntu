#!/bin/sh -x
if [ -S /var/run/fail2ban/fail2ban.sock ]; then
  rm /var/run/fail2ban/fail2ban.sock
fi
service fail2ban start
/usr/sbin/asterisk -vvvvvvv
