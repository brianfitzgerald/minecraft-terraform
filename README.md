# Minecraft on AWS

You will need to generate your own keypair, and configure that as a variable

* generate resources
* upgrade java version on ec2
* spin up server on ec2 instance
* back up world to s3 bucket on cron

## starting the server

* sudo yum install java-1.8.0-openjdk.x86_64
* sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
* java -Xms1G -Xmx1G -jar minecraft_server.1.12.2.jar

## Todo

* startup command, that downloads minecraft, sets the eula, and does automated backups to the s3 bucket 