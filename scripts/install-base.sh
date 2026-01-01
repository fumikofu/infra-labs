#!/usr/bin/expect -f

if {$argc != 3} {
    puts stderr "usage: $argv0 <iso> <disk> <repo-branch>"
    exit 2
}

set timeout 600
set iso  [lindex $argv 0]
set disk [lindex $argv 1]
set ver  [lindex $argv 2]

set prompt {localhost:~# }

spawn qemu-system-x86_64 \
    -m 1024 \
    -smp 2 \
    -nographic \
    -drive file=$disk,format=qcow2,if=virtio \
    -cdrom $iso \
    -nic user,model=virtio

expect "localhost login:"
send "root\r"

expect -exact $prompt
send "ip link set eth0 up\r"

expect -exact $prompt
send "udhcpc -i eth0\r"

expect -exact $prompt
send "printf '%s\\n' \"https://dl-cdn.alpinelinux.org/alpine/v$ver/main\" \"https://dl-cdn.alpinelinux.org/alpine/v$ver/community\" > /etc/apk/repositories\r"

expect -exact $prompt
send "apk update\r"

expect -exact $prompt
send "ERASE_DISKS=/dev/vda BOOTLOADER=grub setup-disk -m sys /dev/vda\r"

expect "Installation is complete"

send "poweroff\r"

expect eof

set result [wait]
set os_error [lindex $result 2]
set exit_code [lindex $result 3]

if {$os_error != 0 || $exit_code != 0} {
    file delete -force -- $disk
    exit 1
}

exit 0
