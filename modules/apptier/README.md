### >>> Connect to Instance
	sudo -su ec2-user

### >> Configure Database

1. Start by downloading the MySQL CLI:

sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
sudo yum install -y mysql

2. Initiate your DB connection with your Aurora RDS writer endpoint. In the following command, replace the RDS writer endpoint and the username, and then execute it in the browser terminal:

mysql -h CHANGE-TO-YOUR-RDS-ENDPOINT -u CHANGE-TO-USER-NAME -p

You will then be prompted to type in your password. Once you input the password and hit enter, you should now be connected to your database.
NOTE: If you cannot reach your database, check your credentials and security groups.

3. Create a database called webappdb with the following command using the MySQL CLI:

CREATE DATABASE webappdb;   

4. You can verify that it was created correctly with the following command:

SHOW DATABASES;

5. Create a data table by first navigating to the database we just created:

USE webappdb;    

6. Then, create the following transactions table by executing this create table command:

CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL
AUTO_INCREMENT, amount DECIMAL(10,2), description
VARCHAR(100), PRIMARY KEY(id));    

7. Verify the table was created:

SHOW TABLES;    

8. Insert data into table for use/testing later:

INSERT INTO transactions (amount,description) VALUES ('400','groceries');   

9. Verify that your data was added by executing the following command:

SELECT * FROM transactions;

10. exit


### >> Configure App Instance

11. verify Upload the app-tier folder to the S3 bucket that you created 

12. Go back to your SSM session. Now we need to install all of the necessary components to run our backend application. Start by installing NVM (node version manager).

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc

13. Next, install a compatible version of Node.js and make sure it's being used

nvm install 16
nvm use 16

14. PM2 is a daemon process manager that will keep our node.js app running when we exit the instance or if it is rebooted. Install that as well.

npm install -g pm2   

15. Now we need to download our code from our s3 buckets onto our instance. In the command below, replace BUCKET_NAME with the name of the bucket you uploaded the app-tier folder to:

cd ~/
aws s3 cp s3://BUCKET_NAME/app-tier/ app-tier --recursive

16. Navigate to the app directory, install dependencies, and start the app with pm2.

cd ~/app-tier
npm install
pm2 start index.js

To make sure the app is running correctly run the following:

pm2 list

If you see a status of online, the app is running. If you see errored, then you need to do some troubleshooting. To look at the latest errors, use this command:

pm2 logs

**NOTE:**
 If you’re having issues, check your configuration file for any typos, and double check that you have followed all installation commands till now.

17. Right now, pm2 is just making sure our app stays running when we leave the SSM session. However, if the server is interrupted for some reason, we still want the app to start and keep running. This is also important for the AMI we will create:

pm2 startup

After running this you will see a message similar to this.

To setup the Startup Script, copy/paste the following command:
 sudo env PATH=$PATH:/home/ec2-user/.nvm/versions/node/v16.0.0/bin /home/ec2-user/.nvm/versions/node/v16.0.0/lib/node_modules/pm2/bin/pm2 startup systemd -u ec2-user —hp /home/ec2-user

**Note :**
DO NOT run the above command, rather you should copy and past the command in the output you see in your own terminal. After you run it, save the current list of node processes with the following command:

pm2 save
