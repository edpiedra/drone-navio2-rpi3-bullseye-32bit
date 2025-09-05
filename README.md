# Overview
Project for a drone with a Raspberry Pi 3, a Navio2 flight controller board, and the Raspian 32-bit OS version Bookworm.

# Cloning
```
sudo apt update && sudo apt install -y git
cd ~ && git clone https://github.com/edpiedra/drone-navio2-rpi3-bullseye-32bit.git drone
sudo bash drone/install/install.sh
# will ask to reboot a few times.  Run the same bash script when it restarts.
```

# Pulling updates
```
cd drone
git pull origin
```

# Reinstall
```
bash drone/install/install.sh --reinstall
```
