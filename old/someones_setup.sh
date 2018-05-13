#!/bin/sh

runMinecraftCommand="java -Xms256M -Xmx768M -jar minecraft_server.jar nogui"
startScript="start.sh"

echo "Great let's get minecraft setup!"
# Sanity check, do we have java installed?
if ! hash java 2>/dev/null; then
    echo "You don't have java installed. You're gonna have a tough time."
    echo "Are you sure you selected the default Amazon Linux HVM ami?"
    exit
fi

# Create the minecraft directory to store server files and change into the directory
if [ ! -d "minecraft" ]; then
    mkdir ~/minecraft
fi
cd ~/minecraft

# Ask which minecraft version to download
echo "Which version of minecraft server do you want to install? e.g. 1.9.2"
read VER

echo "Downloading minecraft server version $VER..."

wget "https://s3.amazonaws.com/Minecraft.Download/versions/$VER/minecraft_server.$VER.jar" -O minecraft_server.jar 2>&1 | grep "403" &> /dev/null

# Check the minecraft download request didn't respond with a 403, invalid server version requested
if [ $? == 0 ]; then
   echo "Looks you requested an invalid server version."
   echo "Run the script again and try again :)"
   exit
fi

if [ ! -f "minecraft_server.jar" ]; then
    echo "The minecraft server download must've failed. Run the script again."
    exit
fi

echo "Minecraft server downloaded successfully!"

# Create a start minecraft shell script which we can run on reboot of our server instance or start it whenever
touch $startScript
cat > $startScript <<- EOM
#!/bin/sh
cd ~/minecraft
screen -dmS minecraft $runMinecraftCommand
EOM

if [ ! -f $startScript ]; then
    echo "Was unable to create a start script for server. Try again."
    exit
fi

# Make the start script executable
chmod 755 $startScript

# Let's start up minecraft and accept any eula agreements if they are created
bash $startScript
sleep 5
screen -S minecraft -X quit &> /dev/null

# If server creates a eula.txt file, update the value false to true
if [ -f "eula.txt" ]; then
    LC_ALL="en_US.UTF-8" perl -pi -e 's/false/true/g' eula.txt
fi

# Remove crontab in case we've already set it up from previous run of script
crontab -r &>/dev/null
# Add command to our crontab to start minecraft on reboot of our server instance
(crontab -l &>/dev/null; echo "@reboot /home/ec2-user/minecraft/$startScript") | crontab -

# Let's run our start script, our minecraft server should be good to go!
bash $startScript
sleep 3

# Check our minecraft instance is running in a deteched session
screen -ls | grep "minecraft" &> /dev/null
if [ $? != 0 ]; then
   echo "Looks something went wrong with our setup. Uh oh...."
   exit
fi

if [ ! -f ~/.bashrc ]; then
    # .bashrc file doesn't exist, create one
    touch ~/.bashrc
fi

# Let's setup some bash aliases for easy stopping/starting of server
# Check to see if aliases are already in .bashrc file
grep "alias minecraft-stop" ~/.bashrc &> /dev/null
if [ $? == 1 ]; then
# Aliases don't exist, append to end of .bashrc file
cat <<EOT >> ~/.bashrc
# Commands to start and stop the minecraft server client
alias minecraft-start="bash ~/minecraft/$startScript && echo minecraft server started"
alias minecraft-stop="screen -S minecraft -X quit && echo minecraft server stopped"
EOT
fi

# Get the Public DNS of Server Instance
publicDNSName=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

echo "Looks like minecraft is setup correctly and running!"
echo "Use the Public DNS of your instance for the \"Server Address\" in your Minecraft Client to play!"
echo -e "\nPublic DNS: $publicDNSName\n"