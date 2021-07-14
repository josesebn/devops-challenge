Infrastructure Coding Test
==========================

1. Run the terraform script to install the VPC and run the EC2 server. 
Note: Create a key pair my-key and save it in the same folder.
   The script creates: EC2 instance,Security group, Internet gateway. Route table and association,Public subnet,ELB
   
   Copy the version file to the running ec2 instance
   
   scp -i "my-key" ./version.txt ec2-user@<public_ip>/.
   
   Or copy it from the s3 bucket created
   
   sudo aws s3 cp s3://jose33/version.txt version.txt
   
2. To scp into the ec2 instance from console using ssh
   chmod 400 my-key
   ssh -i "my-key" ec2-user@<Public IPv4 DNS from ec2>
   ssh works fine!
3. To see the public page open the public DNS name from the ec2 instance created.
4. Run the runChec cript : ./runcheck.sh <Public IPv4 DNS from ec2>
   
