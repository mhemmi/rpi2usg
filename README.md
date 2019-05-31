# rpi2usg
Connect a Raspberry Pi with a Unifi USG 3P
- Need this page because all the other scripts don't forward the traffic through the VPN tunnel
- So the error was: VPN connection successful but no traffic

#using connect.sh 
1. download
2. edit in connect.sh 
VPN_SERVER_IP='\<your server ip>'
VPN_IPSEC_PSK='\<your PSK>'
VPN_USER='\<your username>'
VPN_PASSWORD='\<your password>'

3. sudo sh connect.sh
4. wget -qO- ifconfig.co #shows now your new IP via VPN
5. finish
