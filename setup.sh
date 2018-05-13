# Download Java
wget --no-cookies \
--no-check-certificate \
--header "Cookie: oraclelicense=accept-securebackup-cookie" \
http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.rpm

# Install Java
sudo rpm -i jdk-8u171-linux-x64.rpm

# Download Minecraft
wget https://launcher.mojang.com/mc/game/1.12.2/server/886945bfb2b978778c3a0288fd7fab09d315b25f/server.jar
# Run Minecraft
java -Xmx1024M -Xms1024M -jar server.jar