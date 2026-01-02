#!/usr/bin/expect -f

if {$argc != 3} {
    puts stderr "usage: $argv0 <disk> <k3s-binary-url> <k3s-sha256>"
    exit 2
}

set timeout 600
set disk      [lindex $argv 0]
set k3s_url   [lindex $argv 1]
set k3s_sha256 [lindex $argv 2]

set prompt {localhost:~# }

spawn qemu-system-x86_64 \
    -m 1024 \
    -smp 2 \
    -nographic \
    -drive file=$disk,format=qcow2,if=virtio \
    -nic user,model=virtio

expect "localhost login:"
send "root\r"

expect -exact $prompt
send "ip link set eth0 up\r"

expect -exact $prompt
send "udhcpc -i eth0\r"

expect -exact $prompt
send "apk update\r"

expect -exact $prompt
send "apk add openssh-server curl git qemu-guest-agent\r"

expect -exact $prompt
send "curl -fSL -o /usr/local/bin/k3s $k3s_url\r"

expect -exact $prompt
send "chmod 0755 /usr/local/bin/k3s\r"

expect -exact $prompt
send "echo '$k3s_sha256  /usr/local/bin/k3s' | sha256sum -c - || exit 42\r"
expect {
    -exact $prompt {}
    eof {
        puts stderr "checksum verification failed"
        file delete -force -- $disk
        exit 1
    }
}

send "k3s --version\r"

expect -exact $prompt
send "rm -rf /var/cache/apk/*\r"

expect -exact $prompt
send "sync\r"

expect -exact $prompt
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
