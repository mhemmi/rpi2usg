# ORIGINAL SOURCE FROM https://gist.github.com/danielv99/ae6dbd6d3f5b8fe4241519f5a0733ff3
# Requirements
# debian/ubuntu

#install software
apt-get -y update && apt-get -y upgrade
apt-get -y install strongswan xl2tpd libstrongswan-standard-plugins libstrongswan-extra-plugins

VPN_SERVER_IP='<your server ip>' # @<your hostname> could also work
VPN_IPSEC_PSK='<your PSK>'
VPN_USER='<your username>'
VPN_PASSWORD='<your password>'

cat > /etc/ipsec.conf <<EOF
config setup
conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes256-sha256-modp2048!
  esp=aes128-md5!
conn VPN1
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
  rightid=%any
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[lac VPN1]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client

service strongswan restart
service xl2tpd restart

cat > /usr/local/bin/start-vpn <<EOF
#!/bin/bash
(service strongswan start ;
sleep 2 ;
service xl2tpd start) && (
ipsec up VPN1
echo "c VPN1" > /var/run/xl2tpd/l2tp-control
sleep 5
#ip route add 10.0.0.0/24 dev ppp0
)
EOF
chmod +x /usr/local/bin/start-vpn

cat > /usr/local/bin/stop-vpn <<EOF
#!/bin/bash
(echo "d myvpn" > /var/run/xl2tpd/l2tp-control
ipsec down myvpn) && (
service xl2tpd stop ;
service strongswan stop)
EOF
chmod +x /usr/local/bin/stop-vpn

echo "To start VPN type: start-vpn"
echo "To stop VPN type: stop-vpn"

start-vpn
sudo ip route
sleep 1
sudo route add $VPN_SERVER_IP gw $(ip route show default | awk '/default/ {print $3}')
sudo route add default dev ppp0

