#!/bin/bash

# setup ssh access
sudo sed -i \
  's/^#PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config

sudo systemctl restart sshd

