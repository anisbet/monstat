# monstat
Starts and monitors status of an arbitrary script.

# Files
- `commands` - Contains the commands you wish to check running then start. Blank lines and lines that start with `#` are ignored.
- `monstat.log` - Ongoing log file of events.
- `monstat.notified` - Keeps track of the last time staff were notified, and if the service failed and was not emailed today, then an email will be sent. Read; an email about a failed service will be sent once a day for every day of failure.
- `monstat.tries` - Keeps track of the number of times attempts were made to start the service. If the service was started successfully, the count is zero-ed out.
- `README.md` - This file.
- `monstat.sh` - Application script.
- `LICENSE` - Nuff said.
- `test.sh` - Simple background-able script to test various features.

# Use cases
## Starts Background Service Successfully
`monstat` keeps track of two long running processes: `./monstat.sh --retry=4 --daemon --commands=./commands` where `commands` contains `/home/anisbet/Dev/EPL/monstat/test.sh 5` and `/home/anisbet/Dev/EPL/monstat/test2.sh 15`.

```bash
[2023-06-16 10:35:47] Starting '/home/anisbet/Dev/EPL/monstat/test.sh 5' daemon, attempt no. 1
[2023-06-16 10:35:47] Starting '/home/anisbet/Dev/EPL/monstat/test2.sh 15' daemon, attempt no. 1
sleep time of 5 seconds is over
[2023-06-16 10:35:52] Starting '/home/anisbet/Dev/EPL/monstat/test.sh 5' daemon, attempt no. 1
sleep time of 5 seconds is over
[2023-06-16 10:35:58] Starting '/home/anisbet/Dev/EPL/monstat/test.sh 5' daemon, attempt no. 1
sleep time of 15 seconds is over
[2023-06-16 10:36:03] Starting '/home/anisbet/Dev/EPL/monstat/test2.sh 15' daemon, attempt no. 1
sleep time of 5 seconds is over
[2023-06-16 10:36:04] Starting '/home/anisbet/Dev/EPL/monstat/test.sh 5' daemon, attempt no. 1
sleep time of 5 seconds is over
sleep time of 15 seconds is over
```

## Start Two Daemon Services But One Fails
Application keeps track of two long running processes: `./monstat.sh --retry=4 --daemon --commands=./commands` where `commands` contains `/home/anisbet/Dev/EPL/monstat/test.sh 5` and `/home/anisbet/Dev/EPL/monstat/test2.sh 15`, but `test2.sh` does not exist.
```bash
[2023-06-16 10:51:59] Starting '/home/anisbet/Dev/EPL/monstat/test.sh 5' daemon, attempt no. 1
[2023-06-16 10:51:59] Starting '/home/anisbet/Dev/EPL/monstat/test2.sh 15' daemon, attempt no. 1
[2023-06-16 10:52:00] *warning, attempt # 2 to start /home/anisbet/Dev/EPL/monstat/test2.sh 15 as daemon
[2023-06-16 10:52:01] *warning, attempt # 3 to start /home/anisbet/Dev/EPL/monstat/test2.sh 15 as daemon
[2023-06-16 10:52:02] *warning, attempt # 4 to start /home/anisbet/Dev/EPL/monstat/test2.sh 15 as daemon
[2023-06-16 10:52:03] **error, test2.sh daemon failed to start after 4 attempts
[2023-06-16 10:52:03] someone@example.com emailed about test2.sh failure on Fri 16 Jun 2023 10:52:03 AM EDT
[2023-06-16 10:52:03] **Attention, as of Fri 16 Jun 2023 10:52:03 AM EDT application test2.sh is NOT running and failed to restart. 
Please investigate.

[2023-06-16 10:52:03] *error, no mail service !
sleep time of 5 seconds is over
```

## Starts Two Non-Daemon Scripts Successfully
Run from the command line as `./monstat.sh --retry=4 --commands=./commands2` with commands of `ls -a` and `echo "hello world"` which produces the following.
```bash
[2023-06-16 10:59:18] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 10:59:18] command 'echo "hello world"' output:
"hello world"
```

## Fails to Start Foreground Service
Run from the command line as `./monstat.sh --retry=4 --commands=./commands2` with commands of `ls -a` and `smello "hello world"` which produces the following.
```bash
[2023-06-16 11:03:07] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 11:03:07] command 'smello "hello world"' failed.
[2023-06-16 11:03:10] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 11:03:10] command 'smello "hello world"' failed.
[2023-06-16 11:03:33] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 11:03:33] command 'smello "hello world"' failed.
[2023-06-16 11:03:34] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 11:03:34] command 'smello "hello world"' failed.
[2023-06-16 11:03:35] command 'ls -a' output:
.
..
commands
 (continues...)
test.sh
[2023-06-16 11:03:35] command 'smello "hello world"' failed.
[2023-06-16 11:03:35] **error, smello failed to run after 4 attempts
[2023-06-16 11:03:35] someone@example.com emailed about smello failure on Fri 16 Jun 2023 11:03:35 AM EDT
[2023-06-16 11:03:35] **Attention, as of Fri 16 Jun 2023 11:03:35 AM EDT application smello is NOT running and failed to restart.
Please investigate.

[2023-06-16 11:03:35] *error, no mail service !
```
