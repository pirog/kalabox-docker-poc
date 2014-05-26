# Comments must be on their own lines; inline comments are not supported.

# name of boot2docker virtual machine
VM = "Kalabox"

# path to boot2docker ISO image
ISO = ".boot2docker/boot2docker.iso"

# VM disk image size in MB
DiskSize = 20000

# VM memory size in MB
Memory = 2048

# host-only network host IP
HostIP = "1.3.3.1"

# host only network network mask
NetMask = [255, 255, 255, 0]

# host-only network DHCP server IP
DHCPIP = "1.3.3.2"

# host-only network DHCP server enabled
DHCPEnabled = true

# host-only network IP range lower bound
LowerIP = "1.3.3.7"

# host-only network IP range upper bound
UpperIP = "1.3.3.8"
