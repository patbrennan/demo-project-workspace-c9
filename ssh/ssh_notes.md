# Secure Shell Course

> See Digital Ocean's tutorials (here)[https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04] & (here)[https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets] for more useful information & how-to's.

***SSH***: Just a network protocol that securely exchanges data b/w two computers. Mainly, to execute commands on another computer.

For Ubuntu distributions:

Test if SSH is installed by using `ssh -V`. If it is not, type in: `apt-get install openssh-server openssh-clients`. Start the servers by running the command `/etc/init.d/ssh start`.

To verify it is running, type `service ssh status`.

### Using SSH

**Connect to Remote Host**:

1. Open Terminal
2. Type in `ssh -l USERNAME REMOTE_IP_ADDRESS` (-l is option to specify username)
3. You may get a message asking if you want to continue connecting, because the remote host is not added to the remote hosts file. Type `yes` and it will add the remote host to the proper file so this warning won't appear again.
4. Type in the password.
5. You are logged in.
6. If you type in `whoami` it will show your username
7. `pwd` will show the present working directory.

To exit, type `exit`, which will logout & close the connection.

8. Alternatively to connect, use `ssh USERNAME@REMOTE_IP`.
9. Enter password.

You can see the remote_hosts file:

`cat /root/.ssh/known_hosts` = IP, ecryption, and public key will show.

**Connect using different port**:

Most of the time, SSH will use port 22.

Change default port on remote host:
- On remote host, use `vi /etc/ssh/sshd_config` to edit the file
- Press `i` to edit.
- On line that says "Port 22", remove the hash & change the number to the new SSH port.
- Press `ESC` then `wq` to save the file.
- Restart the ssh service with `/etc/init.d/ssh restart`
- Stop the firewall service

`ssh -p PORT USERNAME@REMOTE_IP` - will connect to that specific port.

**Connect to specific directory**: `ssh -t USERNAME@REMOTE_IP "cd /home/path/to/directory ; bash"`

**Issue command to remote host**: `ssh USERNAME@REMOTE_IP "command to issue"`


### SCP - secure copy

**Copy files to remote host**: `scp FILENAME USERNAME@REMOTE_IP:/path/to/folder`

For multiple files: `scp FILE1 FILE2 FILE3 USERNAME@REMOTE_IP:/path/to_folder`

**Copy files FROM a remote host**:
1. Change into the directory you wish to copy into
2. `scp USERNAME@REMOTE_IP:/path/to-file/filename.txt .` <= "." means download to current working directory.

**Copy ENTIRE directory**: `scp -r /path/to/directory USERNAME@REMOTE_IP:/name_of_new_dir`

To do it FROM the remote host, enter: `scp -r USERNAME@REMOTE_IP:/path/to/copy /new/local/path`. EX: `scp -r root@192.168.8.54:/root/Downloads /root`

### SFTP - secure file transfer protocol

Connect using: `sftp USERNAME@REMOTE_IP`. This will connect you via sftp. TO disconnect, type `bye`.

### Screen - Running multiple shell windows from single SSH sessions

1. Run `sudo apt-get install screen` if it's not already installed.
2. Press `ctrl + a + c` to get another screen pre-authenticated w/ssh
3. Press `ctrl + a + n` will switch screens in order, or `ctrl + a + p` for previous screens.



