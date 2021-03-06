#!/usr/bin/expect

set host [lindex $argv 0];
set user_password [lindex $argv 1];
set root_password [lindex $argv 2];
set master [lindex $argv 3];
set minion_identifier [lindex $argv 4];

if {$argc == 6} {
    set proxy [lindex $argv 5];
}

spawn ssh -o StrictHostKeyChecking=no $host
expect "password:"

send "$user_password\n"
set user_prompt {\$ $}
expect -re $user_prompt

send "su - root\n"
expect "Password:"

send "$root_password\n"
expect ":~#"

set timeout 600

send "mkdir -p /etc/salt/minion.d\n"
expect ":~#"

send "echo 'master: $master' | tee /etc/salt/minion.d/minion.conf\n"
expect ":~#"

send "echo $minion_identifier | tee /etc/salt/minion_id\n"
expect ":~#"

if {$argc == 6} {
    send "export http_proxy=http://$proxy\n"
    expect ":~#"
}

send "wget --quiet --output-document - cfg.greenshininglake.org/virtual-system.sh | sh -e\n"
expect ":~#"

set timeout 10

send "exit\n"
expect -re $user_prompt

send "exit\n"
expect eof
