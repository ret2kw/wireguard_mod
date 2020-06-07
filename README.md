# wireguard_mod
Dockerfile for building and loading the Wireguard module on Docker Desktop

Docker Desktop occasionally removes modules that normally come distributed with linuxkit. The build script will run another container that pulls the kernel version so we can then pull the appropriate Docker distributed container with the linux source for Docker Desktop. Then compiles the Wireguard module and runs the container loading the module. The build.sh script should only need to be run once per reboot. 