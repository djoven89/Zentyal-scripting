# **Zentyal Checker**

The goal of this script is to automate the basic tasks that a SysAdmin should perform every day on the Zentyal Server to ensure that the server is working fine.

### What checks does the script ?

1. The available partition space.

2. Broken packages in the Zentyal server.

3. Available packages for update.

4. Emails in the root local account.

5. The status of each database of Mysql.

6. The number of errors and warnings that the server has in its modules.

### How to use this script

1. Download the script in the Zentyal server and stores it in '**/usr/local/bin/**':

2. Set the proper permissions:

        chmod 0750 /usr/local/bin/zentyal-checker.sh
        chown root:root /usr/local/bin/zentyal-checker.sh

3. Confirm that the script run successfully by running it with admin rights:

        sudo zentyal-checker.sh

4. Create a cronjob in order to run the script automatic everyday:

        echo "0 23 * * * root /usr/local/bin/zentyal-checker.sh" > /etc/cron.d/zentyal-checker 

5. In case you want to receive an email after the cronjob run, you can add this line at the beginning of the cronjob:

        MAILTO="user_mail@domain_name"
