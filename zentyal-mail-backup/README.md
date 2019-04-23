# **Zentyal Mail Backup Script**

This script will backup the Mail and/or Sogo modules.

### Arguments available

* "**-d domain_name**" -> The Virtual Mail Domain that you want to backup for the Mail module. This option is mandatory if you want to backup Mail module and must be set before '-m' option.
* "**-D stored_location**" -> The location where you want to store the backups. This option is mandatory and must be set before '-m' or '-s' options.
* "**-m**" -> For Mail backup.
* "**-s**" -> For Sogo backup.


### Examples

For backup Mail and Sogo modules:

    ./zentyal-mail-backup.sh -d lab6.lan -D /mnt/nas_drive -m -s 

For backup the Mail module only:

    ./zentyal-mail-backup.sh -d lab6.lan -D /mnt/nas_drive -m

For backup the Sogo module only:

    ./zentyal-mail-backup.sh -D /mnt/nas_drive -s


### Considerations

* Make sure that you have enough space before run the script.
* It's recommendable to store the backups in a remote site or device.


### How to use this script

1. Download the script in the Zentyal server and stores it in '/usr/local/bin':

2. Set the proper permissions:

        chmod 0750 /usr/local/bin/zentyal-mail-backup.sh
        chown root:root /usr/local/bin/zentyal-mail-backup.sh

3. Confirm that the script run successfully in your environment by running it (see the '**Examples**' section).

4. Create a cronjob, for example, to run this script each day at 23:00, backup both modules for the virtual mail domain 'lab6.lan' and store them in the directory '/mnt/daily_backups/':

        echo "0 23 * * * root /usr/local/bin/zentyal-mail-backup.sh -d lab6.lan -D /mnt/daily_backups/ -s -m" > /etc/cron.d/zentyal-mail-backup 

5. In case you want to receive an email after the cronjob run, you can add this line at the beginning of the cronjob:

        MAILTO="user_mail@domain_name"


### Troubleshooting

In case you get some error when you run the script, you can add '**set -x**' in the second line of the script and it will print all the actions it does.

To see if the script was runned in the cronjob, you can check the log file: '*/var/log/syslog*' or use the command: '**journalctl -u cron**' .
