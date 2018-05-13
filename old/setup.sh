#!/bin/sh

echo Updating Java...

sudo yum install java-1.8.0-openjdk.x86_64
sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

echo "Which version of minecraft server do you want to install? e.g. 1.9.2"
read VER

echo Installing Minecraft...

wget "https://s3.amazonaws.com/Minecraft.Download/versions/$VER/minecraft_server.$VER.jar" -O minecraft_server.jar 2>&1 | grep "403" &> /dev/null

if [ -f "eula.txt" ]; then
    LC_ALL="en_US.UTF-8" perl -pi -e 's/false/true/g' eula.txt
fi

java -Xms1G -Xmx1G -jar minecraft_server.jar