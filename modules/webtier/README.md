### >> Update Config File

1. verify your config file it is updated or not
Before we create and configure the web instances, open up the application-code/nginx.conf file from the repo we downloaded.
Scroll down to line 58 and replace [INTERNAL-LOADBALANCER-DNS] with your internal load balancer’s DNS entry. You can find this by navigating to your internal load balancer's details page.

**>>> Web Instance Deployment**

1. Follow the same steps you used to connect to the app instance and change the user to ec2-user. Test connectivity here via ping as well since this instance should have internet connectivity:
sudo -su ec2-user 
ping 8.8.8.8

**Note:** If you don't see a transfer of packets then you'll need to verify your route tables attached to the subnet that your instance is deployed in.

2. We now need to install all of the necessary components needed to run our front-end application. Again, start by installing NVM and node :

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
nvm install 16
nvm use 16

3. Now we need to download our web tier code from our s3 bucket:

cd ~/
aws s3 cp s3://BUCKET_NAME/web-tier/ web-tier --recursive

Navigate to the web-layer folder and create the build folder for the react app so we can serve our code:

cd ~/web-tier
npm install 
npm run build

4. NGINX can be used for different use cases like load balancing, content caching etc, 
but we will be using it as a web server that we will configure to serve our application on port 80, as well as help direct our API calls to the internal load balancer.

sudo yum install nginx

5. We will now have to configure NGINX. Navigate to the Nginx configuration file with the following commands and list the files in the directory:

cd /etc/nginx
ls

You should see an nginx.conf file. We’re going to delete this file and use the one we uploaded to s3. 
Replace the bucket name in the command below with the one you created for this workshop:

sudo rm nginx.conf
sudo aws s3 cp s3://BUCKET_NAME/nginx.conf .

6. Then, restart Nginx with the following command:

sudo service nginx restart

To make sure Nginx has permission to access our files execute this command:

chmod -R 755 /home/ec2-user

And then to make sure the service starts on boot, run this command:

sudo chkconfig nginx on 