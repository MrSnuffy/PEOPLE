clear
echo -e "\n\n\n\n\n\n\n"
if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as \"root\" OR as \"sudo $USER\"; please try again." 1>&2
  exit 1
fi
#
# BEGIN WELCOME SCREEN & INITIAL UPDATING
#
clear
echo -e "\n\n\n\n\n\n\n"
echo "     Welcome to PEOPLE, where we'll be..." 
echo "Placing Elastic On Premise Lovingly & Expeditiously"
echo -e "\n\n\n\n\n\n\n"
echo "You can choose to either:"
echo ""
echo "Install a secure Elastic Cloud Enterprise instance in a 1-2 process for CentOS7" 
echo ""
echo "Configure the Elastic repository and install a single insecure node of Elastic, Logstash, & Kibana" 
echo ""
echo "Install several Beats, configure Machine Learning & deploy kick-ass dashboards."
echo -e "\n\n\n"
echo "But first we must run a few commands to get ready."
echo -e "\n\n\n"
read -n 1 -s -r -p "Press any key to continue"
echo ""
echo "Enjoy! ☺"
clear
sudo yum install dialog -y
clear
#
cmd=(dialog --radiolist "Which would you like to do?" 22 135 16)
options=(1 "ECE Install Part-1, then reboot." off    # any option can be set to default to "on"
         2 "ECE Install Part-2, and start deploying clusters!." off
         3 "Single ELK Node Install." off
         4 "Beats Installation & Configuration." off
         5 "Make like a tree, and leave." off)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
# ECE INSTALL PART 1
        1)      clear
echo "This is designed to be run on a minimal server install of CentOS 7 AFTER 'yum update' has been run and the system was rebooted."
echo ""
echo "Once done, your system will reboot; once it does start PART 2."
read -n 1 -s -r -p "Press any key to continue"
clear
sudo yum install wget java-1.8* -y
sudo /sbin/grubby --update-kernel=ALL --args='cgroup_enable=memory cgroup.memory=nokmem swapaccount=1'
echo "overlay" | sudo tee -a /etc/modules-load.d/overlay.conf
sudo grub2-set-default 0
sudo grub2-mkconfig -o /etc/grub2.cfg
sudo touch /etc/yum.repos.d/docker.repo
echo "[dockerrepo]" | sudo tee -a /etc/yum.repos.d/docker.repo
echo "name=Docker Repository" |  sudo tee -a /etc/yum.repos.d/docker.repo
echo "baseurl=https://download.docker.com/linux/centos/7/x86_64/stable" | sudo tee -a /etc/yum.repos.d/docker.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/docker.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/docker.repo
echo "gpgkey=https://download.docker.com/linux/centos/gpg" | sudo tee -a /etc/yum.repos.d/docker.repo
sudo yum makecache fast -y
sudo yum install docker-ce-18.09.2* -y
sudo systemctl stop docker
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf
sudo service network restart
echo "* soft nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "* soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
echo "* hard memlock unlimited" | sudo tee -a /etc/security/limits.conf
echo "$USER soft nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "$USER hard nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "$USER soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
echo "$USER hard memlock unlimited" | sudo tee -a /etc/security/limits.conf
echo "root soft nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "root hard nofile 1024000" | sudo tee -a /etc/security/limits.conf
echo "root soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
sudo install -o $USER -g $USER -d -m 700 /mnt/data
sudo install -o $USER -g $USER -d -m 700 /mnt/data/docker
sudo systemctl disable firewalld
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/docker.conf
echo "[Unit]" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "Description=Docker Service" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "After=multi-user.target" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "[Service]" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "ExecStart=" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
echo "ExecStart=/usr/bin/dockerd --data-root /mnt/data/docker --storage-driver=overlay --bip=172.17.42.1/16" | sudo tee -a /etc/systemd/system/docker.service.d/docker.conf
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo touch /etc/sysctl.d/70-cloudenterprise.conf
echo "net.ipv4.tcp_max_syn_backlog=65536" | sudo tee -a /etc/sysctl.d/70-cloudenterprise.conf
echo "net.core.somaxconn=32768" | sudo tee -a /etc/sysctl.d/70-cloudenterprise.conf
echo "net.core.netdev_max_backlog=32768" | sudo tee -a /etc/sysctl.d/70-cloudenterprise.conf
echo "exclude=docker-ce" | sudo tee -a /etc/yum.conf
echo ""
echo ""
echo ""
clear
echo ""
echo ""
echo ""
echo ""
echo "The system now requires a reboot.  Please re-run the script and choose selection option 2."
echo ""
echo "If you are planning on adding additional ECE nodes or configuring Availability Zones, please"
echo ""
echo "run Part-1 of this script on the additional server, and then run the command generated and"
echo ""
echo "placed in the ECE-Summary.txt after this installation's Part-2 is complete."
echo ""
read -n 1 -s -r -p "Press any key to acknowledge & reboot now."
clear
sudo reboot now
;;
# ECE INSTALL PART 2
2)      clear
if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as \"root\" OR as \"sudo $USER\"; please try again." 1>&2
  exit 1
fi
echo "Welcome to the ECE Auto-Install Script PART 2!"
echo
echo "What would you like to call your primary Availability Zone?"
echo
echo "Some suggestions, if I may, would be:  AZ1, ECE-Zone-1, etc..."
echo
read AZ1
sudo docker info | grep Root
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --availability-zone ${AZ1}
adminPassword=$(grep -oP '(?<=adminconsole_root_password":")[^"]*' /mnt/data/elastic/bootstrap-state/bootstrap-secrets.json)
rolesToken=$(grep -oP '(?<=bootstrap_runner_roles_token":")[^"]*' /mnt/data/elastic/bootstrap-state/bootstrap-secrets.json)
emergencyAllbutAlloToken=$(grep -oP '(?<=emergency_all_roles_except_allocator_token":")[^"]*' /mnt/data/elastic/bootstrap-state/bootstrap-secrets.json)
allocatorOnlyToken=$(grep -oP '(?<=allocator_only_token":")[^"]*' /mnt/data/elastic/bootstrap-state/bootstrap-secrets.json)
echo "Downloading optional versions for your cluster."
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.6.2 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.6.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.6.0 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.5.2 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.5.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.5.0 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.4.2 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.4.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.4.0 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.3.2 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.3.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.3.0 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.2.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.2.0 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 7.1.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 6.8.3 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 6.7.1 --user admin --pass ${adminPassword}
bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) add-stack-version --version 6.7.0 --user admin --pass ${adminPassword}
clear
echo ""
echo ""
echo "What is the IP address of this system?"
read myIP
clear
echo ""
echo ""
PEOPLEUser=$(whoami)
echo "Moving secure bootstrap-secrets.json to ${PEOPLEUser}'s home folder."
echo ""
echo "Please secure both bootstrap-secrets.json & ECE-Summary.txt when finished."
echo ""
PEOPLEUser=$(whoami)
sudo cp /mnt/data/elastic/bootstrap-state/bootstrap-secrets.json /home/${PEOPLEUser}
sudo chmod 777 /home/${PEOPLEUser}/bootstrap-secrets.json
clear
echo ""
echo "Your ECE login username will be \"admin\" and the password is \"${adminPassword}\"."
echo ""
echo ""
echo "You can access ECE via https://${myIP}:12443"
echo ""
echo "These credentials will be located at /home/${PEOPLEUser}/ECE-Summary.txt."
echo ""
PEOPLEUser=$(whoami)
echo "Please store these in a secure location."
echo ""
read -n 1 -s -r -p "Press any key to acknowledge and continue."
echo ""
sudo touch /home/${PEOPLEUser}/ECE-Summary.txt
clear
echo "Access ECE here:  https://${myIP}:12443" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "Login to ECE as \"admin\" with the password \"${adminPassword}\"." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To add additional nodes to this installation, simply re-run Part-1 of this script on the next system." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo ""  | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "Then, instead of running Part-2, merely run one of these commands with the same priviledges as the user with which you started." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To add a node to this Availability Zone:" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --coordinator-host ${myIP} --roles-token '${rolesToken}'" --availability-zone AZ1| sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo ""  | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "Once logged into ECE, assign the roles you wish within the 'Platform' sub-menu."
echo ""  | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo ""  | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To add a node to Availability Zone 2:" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --coordinator-host ${myIP} --roles-token '${rolesToken}'" --availability-zone AZ2| sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To add a node to Availability Zone 3:" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --coordinator-host ${myIP} --roles-token '${rolesToken}'" --availability-zone AZ3| sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "Once logged into ECE, assign the roles you wish within the 'Platform' sub-menu."| sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo ""  | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "Your Persistent All Roles Token is:" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
curl -H 'Content-Type: application/json' -u admin:${adminPassword} https://${myIP}:12443/api/v1/platform/configuration/security/enrollment-tokens -d '{ "persistent": true, "roles": [ "director", "coordinator", "proxy", "allocator"] }' -k | sudo tee -a /home/$USER/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To use the Persistent Token to add all roles in AZ2, run this command after Part-1 completes a reboot." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
allRolesToken=$(grep -oP '(?<=token": ")[^"]*' /home/${PEOPLEUser}/ECE-Summary.txt)
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --coordinator-host ${myIP} --roles-token '${allRolesToken}' --roles \"director,coordinator,proxy,allocator\" --availability-zone AZ2" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "To use the Persistent Token to add all roles in AZ3, run this command after Part-1 completes a reboot." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
allRolesToken=$(grep -oP '(?<=token": ")[^"]*' /home/${PEOPLEUser}/ECE-Summary.txt)
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "bash <(curl -fsSL https://download.elastic.co/cloud/elastic-cloud-enterprise.sh) install --coordinator-host ${myIP} --roles-token '${allRolesToken}' --roles \"director,coordinator,proxy,allocator\" --availability-zone AZ3" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "The initial token provided by this script during installation will expire; so if you plan on expanding your cluster over time, you can use this Persistent Token with the generated script above.  If you wish to generate role specific tokens, simply review this code and modify for your values.  This script is not officially supported by Elastic, but is designed to simplify the installation process.  Some modification may be required to tune for your environment.  By continuing you are acknowledging that you have read this in its entirety." | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
echo "" | sudo tee -a /home/${PEOPLEUser}/ECE-Summary.txt
read -n 1 -s -r -p "Press any key to accept and take ECE for a spin."
clear
;;
# ELK NODE INSTALL 
3)      clear
echo "Import Elastic gpg key"
echo ""
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "Import Elastic gpg key:                                           $(tput setaf 2)[$(tput setaf 4)OK$(tput setaf 2)]$(tput setaf 7)"
#
#
# create Elastic repo
echo "Creating Elastic repository"
echo
sudo touch /etc/yum.repos.d/elasticsearch.repo
echo "[elasticsearch-7.x]" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "name=Elasticsearch repository for 7.x packages" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
sudo yum install elasticsearch-7* kibana-7* logstash-7* java-1.8* -y
clear
echo ""
echo "WARNING:"
echo "Stopping and disabling firewalld for accessibility purposes."
echo ""
echo "Do NOT do this in production OR allow ports 9200 & 5601."
echo ""
read -n 1 -s -r -p "Press any key to agree and continue."
clear
echo ""
sudo systemctl stop firewalld
sudo systemctl disable firewalld
echo "Firewall stopped and disabled on boot."
echo
echo
echo
read -n 1 -s -r -p "Press any key to continue"
clear
echo ""
sudo mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak
echo "What is the IPv4 address of this system?"
echo 
read elkIP
echo 
echo "Please set the Elastic Cluster name.  This is cosmetic only."
echo 
read elkClusterName
echo 
echo "Please set the Elastic Node name.  This is cosmetic only."
echo 
read elkNodeName
echo 
sudo touch /etc/elasticsearch/elasticsearch.yml
echo "# ======================== Elasticsearch Configuration =========================" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo -e "cluster.name: ${elkClusterName}" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo -e "node.name: ${elkNodeName}" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "path.data: /var/lib/elasticsearch" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "path.logs: /var/log/elasticsearch" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo -e "network.host: ${elkIP}" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "http.port: 9200" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "discovery.seed_hosts: [\"${elkIP}\"]" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "cluster.initial_master_nodes: [\"${elkIP}\"]" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "xpack.license.self_generated.type: trial" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "#" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "# ======================== Elasticsearch Configuration =========================" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
#
#
# Begin JVM memory configuration.
sudo cp /etc/elasticsearch/jvm.options /etc/elasticsearch/jvm.options.bak
echo "How much RAM would you like to allocate for Elastic?  Typically this is 50% of your physical memory."
echo 
echo "EXAMPLE INPUT: 256M OR 2G"
echo 
read elkRAM
sudo sed -i "22s/.*/-Xms$elkRAM/" /etc/elasticsearch/jvm.options
sudo sed -i "23s/.*/-Xmx$elkRAM/" /etc/elasticsearch/jvm.options
#
# Begin Elasticsearch services and enable at boot.
sudo service elasticsearch start
sudo systemctl enable elasticsearch
#
sudo cp /etc/logstash/jvm.options /etc/logstash/jvm.options.bak
echo 
echo "How much RAM would you like to allocate for Logstash?"
echo
echo "Typically, this 5~10% of physical RAM"
echo 
echo "EXAMPLE INPUT: 256M OR 2G"
echo 
read logRAM
sudo sed -i "6s/.*/-Xms$logRAM/" /etc/logstash/jvm.options
sudo sed -i "7s/.*/-Xmx$logRAM/" /etc/logstash/jvm.options
echo 
#
# Begin Kibana modification.
sudo mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak
echo "Please set the Kibana Server name.  This is cosmetic only."
echo 
read kibName
sudo touch /etc/kibana/kibana.yml
echo "server.port: 5601" | sudo tee -a /etc/kibana/kibana.yml
echo "server.host: \"${elkIP}\"" | sudo tee -a /etc/kibana/kibana.yml
echo "server.name: \"${kibName}\"" | sudo tee -a /etc/kibana/kibana.yml
echo "elasticsearch.hosts: [\"http://${elkIP}:9200\"]" | sudo tee -a /etc/kibana/kibana.yml
#
# Begin Kibana services and enable at boot.
sudo service kibana start
sudo systemctl enable kibana
#
#
clear
echo "It will take a few moments to get Elasticsearch & Kibana up and running."
echo ""
echo "Please open a browser to http://${elkIP}:5601 and get ready to ride the Elastic Slide!!!"
;;
# LET'S INSTALL SOME BEATS AND HAVE SOME FUN
4)      clear
sudo cp /etc/yum.repos.d/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo.bak
echo "[elasticsearch-7.x]" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "name=Elasticsearch repository for 7.x packages" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
sudo yum install filebeat-7* packetbeat-7* metricbeat-7* heartbeat-elastic-7* auditbeat* -y
clear
echo ""
## Set variables for easy coding
# Outputs
pBeatOut="sudo tee -a /etc/packetbeat/packetbeat.yml"
mBeatOut="sudo tee -a /etc/metricbeat/metricbeat.yml"
fBeatOut="sudo tee -a /etc/filebeat/filebeat.yml"
hBeatOut="sudo tee -a /etc/heartbeat/heartbeat.yml"
aBeatOut="sudo tee -a /etc/auditbeat/heartbeat.yml"
# Metricbeat Modules
mBeatSys="sudo tee -a /etc/metricbeat/modules.d/system.yml"
fBeatSys="sudo tee -a /etc/filebeat/modules.d/system.yml"
## End variables for easy coding
sudo metricbeat modules enable system
sudo filebeat modules enable system
clear
echo ""
echo ""
echo "Would you like to configure Beats to feed Elastic now?"
read -p "Continue (y/n)?" choice 
case "$choice" in 
  y|Y ) echo "PEOPLE will now ask for several items to configure Beats.";;
  n|N ) echo "Please come back when you are ready to continue." ; ;;
  * ) echo "Invalid Option";;
  esac
read -n 1 -s -r -p "Press any key to continue"
clear
#
# Make backups and prepare for *beat.yml creation.
#
echo ""
echo "Output Configuration.  Let's do this first, and pass it to all the Beats!"
echo ""
echo "Making a copy of the original '*.yml' file and renaming with the extension .bak in the same location."
echo ""
read -n 1 -s -r -p "Press any key to continue"
echo ""
sudo mv /etc/packetbeat/packetbeat.yml /etc/packetbeat/packetbeat.yml.bak
sudo touch /etc/packetbeat/packetbeat.yml
echo ""
sudo mv /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml.bak
sudo touch /etc/metricbeat/metricbeat.yml
echo ""
sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
sudo touch /etc/filebeat/filebeat.yml
echo ""
sudo mv /etc/heartbeat/heartbeat.yml /etc/heartbeat/heartbeat.yml.bak
sudo touch /etc/heartbeat/heartbeat.yml
echo ""
sudo mv /etc/auditbeat/auditbeat.yml /etc/auditbeat/auditbeat.yml.bak
sudo touch /etc/auditbeat/auditbeat.yml
#
# There can be only one output, so Highlander rules.
#
#
# Beats Output Config Section
#
main_menu () {
    options=(
    "Cloud.Elastic.co"
    "Elastic Cloud Enterprise"
    "ELK Single Unsecured Node"
    "Make like a tree, and leave. :P"
    )
    select option in "${options[@]}"; do
        case $option in
            ${options[0]})
		clear
        echo "Cloud.Elastic.co"
        echo ""
		cloudID=$(dialog --title "What is your Cloud ID?" --backtitle "Cloud ID Input Section" --inputbox "Found in the Elastic Cloud UI:" 8 99 3>&1 1>&2 2>&3 3>&- )
		cloudAuth=$(dialog --title "What is your Cloud Auth?" --backtitle "Cloud Auth Input Section" --inputbox "Typically elastic:somePassword:" 8 99 3>&1 1>&2 2>&3 3>&- )
		echo "This is your Cloud ID:  $cloudID"
		echo "This is your Cloud Auth:  $cloudAuth"
		# PACKETBEAT
		echo "#============================= Elastic Cloud ==================================" | ${pBeatOut}
		echo "cloud.id: ${cloudID}" | ${pBeatOut}
		echo "cloud.auth: ${cloudAuth}" | ${pBeatOut}
		echo "#============================= Elastic Cloud ==================================" | ${pBeatOut}
		# METRICBEAT               
		echo "#============================= Elastic Cloud ==================================" | ${mBeatOut}
        echo "cloud.id: ${cloudID}" | ${mBeatOut}
        echo "cloud.auth: ${cloudAuth}" | ${mBeatOut}
        echo "#============================= Elastic Cloud ==================================" | ${mBeatOut}
		# FILEBEAT
		echo "#============================= Elastic Cloud ==================================" | ${fBeatOut}
        echo "cloud.id: ${cloudID}" | ${fBeatOut}
        echo "cloud.auth: ${cloudAuth}" | ${fBeatOut}
        echo "#============================= Elastic Cloud ==================================" | ${fBeatOut}
		# HEARTBEAT
		echo "#============================= Elastic Cloud ==================================" | ${hBeatOut}
        echo "cloud.id: ${cloudID}" | ${hBeatOut}
        echo "cloud.auth: ${cloudAuth}" | ${hBeatOut}
        echo "#============================= Elastic Cloud ==================================" | ${hBeatOut}
		# AUDITBEAT
		echo "#============================= Elastic Cloud ==================================" | ${aBeatOut}
        echo "cloud.id: ${cloudID}" | ${aBeatOut}
        echo "cloud.auth: ${cloudAuth}" | ${aBeatOut}
        echo "#============================= Elastic Cloud ==================================" | ${aBeatOut}
		#
        break
            ;;
            ${options[1]})
        clear
		echo "Elastic Cloud Enterprise"
		echo ""
    Ehosts=$(dialog --title "ECE Elastic Host (Not Kibana)" --backtitle "ECE Elastic Config Section" --inputbox "Copy & Paste Elasticsearch Endpoint URL" 8 99 3>&1 1>&2 2>&3 3>&- )
		EuserName=$(dialog --title "ECE Username (typically 'elastic')" --backtitle "ECE Elastic Config Section" --inputbox "Username (default is \"elastic\"):" 8 99 3>&1 1>&2 2>&3 3>&- )
		EpassWord=$(dialog --title "ECE Cluster Password (default for 'elastic')" --backtitle "ECE Elastic Config Section" --inputbox "Password:" 8 99 3>&1 1>&2 2>&3 3>&- )
		Khosts=$(dialog --title "ECE Kibana Host (Not Elastic)" --backtitle "ECE Kibana Config Section" --inputbox "Copy & Paste Kibana Endpoint URL" 8 99 3>&1 1>&2 2>&3 3>&- )
		KuserName=$(dialog --title "ECE Cluster Username (default for 'elastic')" --backtitle "ECE Kibana Config Section" --inputbox "Username (default is \"elastic\")" 8 99 3>&1 1>&2 2>&3 3>&- )
		KpassWord=$(dialog --title "ECE Cluster Password (default for 'elastic')" --backtitle "ECE Kibana Config Section" --inputbox "Password:" 8 99 3>&1 1>&2 2>&3 3>&- )
		# PACKETBEAT
    echo "output.elasticsearch:" | ${pBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${pBeatOut}
		echo " username: \"${EuserName}\"" | ${pBeatOut}
		echo " password: \"${EpassWord}\"" | ${pBeatOut}
		echo " ssl.verification_mode: none" | ${pBeatOut}
		echo " protocol: \"https\"" | ${pBeatOut}
		echo "###" | ${pBeatOut}
		echo "# Kibana Config Sub-Section" | ${pBeatOut}
		echo "###" | ${pBeatOut}
		echo "setup.kibana:" | ${pBeatOut}
		echo " host: \"${Khosts}\"" | ${pBeatOut}
		echo " username: \"${KuserName}\"" | ${pBeatOut}
		echo " password: \"${KpassWord}\"" | ${pBeatOut}
		echo " ssl.verification_mode: none" | ${pBeatOut}
		echo " protocol: \"https\"" | ${pBeatOut}
		echo "#=============================== ECE Output ===================================" | ${pBeatOut}		
		# METRICBEAT               
		echo "#=============================== ECE Output ===================================" | ${mBeatOut}
        echo "output.elasticsearch:" | ${mBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${mBeatOut}
		echo " username: \"${EuserName}\"" | ${mBeatOut}
		echo " password: \"${EpassWord}\"" | ${mBeatOut}
		echo " ssl.verification_mode: none" | ${mBeatOut}
		echo " protocol: \"https\"" | ${mBeatOut}
		echo "###" |${mBeatOut}
		echo "# Kibana Config Sub-Section" | ${mBeatOut}
		echo "###" | ${mBeatOut}
		echo "setup.kibana:" | ${mBeatOut}
		echo " host: \"${Khosts}\"" | ${mBeatOut}
		echo " username: \"${KuserName}\"" | ${mBeatOut}
		echo " password: \"${KpassWord}\"" | ${mBeatOut}
		echo " ssl.verification_mode: none" | ${mBeatOut}
		echo " protocol: \"https\"" | ${mBeatOut}
		echo "#=============================== ECE Output ===================================" | ${mBeatOut}
		# FILEBEAT
		echo "#=============================== ECE Output ===================================" | ${fBeatOut}
        echo "output.elasticsearch:" | ${fBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${fBeatOut}
		echo " username: \"${EuserName}\"" | ${fBeatOut}
		echo " password: \"${EpassWord}\"" | ${fBeatOut}
		echo " ssl.verification_mode: none" | ${fBeatOut}
		echo " protocol: \"https\"" | ${fBeatOut}
		echo "###" | ${fBeatOut}
		echo "# Kibana Config Sub-Section" | ${fBeatOut}
		echo "###" | ${fBeatOut}
		echo "setup.kibana:" | ${fBeatOut}
		echo " host: \"${Khosts}\"" | ${fBeatOut}
		echo " username: \"${KuserName}\"" | ${fBeatOut}
		echo " password: \"${KpassWord}\"" | ${fBeatOut}
		echo " ssl.verification_mode: none" | ${fBeatOut}
		echo " protocol: \"https\"" | ${fBeatOut}
		echo "#=============================== ECE Output ===================================" | ${fBeatOut}
		# HEARTBEAT
		echo "#=============================== ECE Output ===================================" | ${hBeatOut}
        echo "output.elasticsearch:" | ${hBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${hBeatOut}
		echo " username: \"${EuserName}\"" | ${hBeatOut}
		echo " password: \"${EpassWord}\"" | ${hBeatOut}
		echo " ssl.verification_mode: none" | ${hBeatOut}
		echo " protocol: \"https\"" | ${hBeatOut}
		echo "###" | ${hBeatOut}
		echo "# Kibana Config Sub-Section" | ${hBeatOut}
		echo "###" | ${hBeatOut}
		echo "setup.kibana:" | ${hBeatOut}
		echo " host: \"${Khosts}\"" | ${hBeatOut}
		echo " username: \"${KuserName}\"" | ${hBeatOut}
		echo " password: \"${KpassWord}\"" | ${hBeatOut}
		echo " ssl.verification_mode: none" | ${hBeatOut}
		echo " protocol: \"https\"" | ${hBeatOut}  
		echo "#=============================== ECE Output ===================================" | ${hBeatOut}
		# AUDITBEAT
		echo "#=============================== ECE Output ===================================" | ${aBeatOut}
        echo "output.elasticsearch:" | ${aBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${aBeatOut}
		echo " username: \"${EuserName}\"" | ${aBeatOut}
		echo " password: \"${EpassWord}\"" | ${aBeatOut}
		echo " ssl.verification_mode: none" | ${aBeatOut}
		echo " protocol: \"https\"" | ${aBeatOut}
		echo "###" | ${aBeatOut}
		echo "# Kibana Config Sub-Section" | ${aBeatOut}
		echo "###" | ${aBeatOut}
		echo "setup.kibana:" | ${aBeatOut}
		echo " host: \"${Khosts}\"" | ${aBeatOut}
		echo " username: \"${KuserName}\"" | ${aBeatOut}
		echo " password: \"${KpassWord}\"" | ${aBeatOut}
		echo " ssl.verification_mode: none" | ${aBeatOut}
		echo " protocol: \"https\"" | ${aBeatOut}  
		echo "#=============================== ECE Output ===================================" | ${aBeatOut}
		#
        break
            ;;
        ${options[2]})
		clear
        echo "ELK Single Unsecured Node"
        echo ""
        Ehosts=$(dialog --title "Elastic Host & Port (e.g. localhost:9200 OR 10.0.0.1:9200)" --backtitle "Elastic On-Prem Config Section" --inputbox "Elastic Host" 8 99 3>&1 1>&2 2>&3 3>&- )
        Khosts=$(dialog --title "Kibana Host (e.g. localhost:5601 OR 10.0.0.1:5601)" --backtitle "Kibana On-Prem Config Section" --inputbox "Kibana Host" 8 99 3>&1 1>&2 2>&3 3>&- )
         # PACKETBEAT
		echo "#=========================== Elastic On-Prem ==================================" | ${pBeatOut}
		echo "output.elasticsearch:" | ${pBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${pBeatOut}
    echo "###" | ${pBeatOut}
		echo "# Kibana Config Sub-Section" | ${pBeatOut}
		echo "###" | ${pBeatOut}
		echo "setup.kibana:" | ${pBeatOut}
		echo " host: \"${Khosts}\"" | ${pBeatOut}
    echo "#=========================== Elastic On-Prem ==================================" | ${pBeatOut}
		# METRICBEAT               
		echo "#=========================== Elastic On-Prem ==================================" | ${mBeatOut}
    echo "output.elasticsearch:" | ${mBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${mBeatOut}
    echo "###" |${mBeatOut}
		echo "# Kibana Config Sub-Section" | ${mBeatOut}
		echo "###" | ${mBeatOut}
		echo "setup.kibana:" | ${mBeatOut}
		echo " host: \"${Khosts}\"" | ${mBeatOut}
    echo "#=========================== Elastic On-Prem ==================================" | ${mBeatOut}
		# FILEBEAT
		echo "#=========================== Elastic On-Prem ==================================" | ${fBeatOut}
        echo "output.elasticsearch:" | ${fBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${fBeatOut}
    echo "###" | ${fBeatOut}
		echo "# Kibana Config Sub-Section" | ${fBeatOut}
		echo "###" | ${fBeatOut}
		echo "setup.kibana:" | ${fBeatOut}
		echo " host: \"${Khosts}\"" | ${fBeatOut}
    echo "#=========================== Elastic On-Prem ==================================" | ${fBeatOut}
		# HEARTBEAT
		echo "#=========================== Elastic On-Prem ==================================" | ${hBeatOut}
        echo "output.elasticsearch:" | ${hBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${hBeatOut}
    echo "###" | ${hBeatOut}
		echo "# Kibana Config Sub-Section" | ${hBeatOut}
		echo "###" | ${hBeatOut}
		echo "setup.kibana:" | ${hBeatOut}
		echo " host: \"${Khosts}\"" | ${hBeatOut}
    echo "#=========================== Elastic On-Prem ==================================" | ${hBeatOut}
		# AUDITBEAT
		echo "#=========================== Elastic On-Prem ==================================" | ${aBeatOut}
        echo "output.elasticsearch:" | ${aBeatOut}
		echo " hosts: [\"${Ehosts}\"]" | ${aBeatOut}
    echo "###" | ${aBeatOut}
		echo "# Kibana Config Sub-Section" | ${aBeatOut}
		echo "###" | ${aBeatOut}
		echo "setup.kibana:" | ${aBeatOut}
		echo " host: \"${Khosts}\"" | ${aBeatOut}
    echo "#=========================== Elastic On-Prem ==================================" | ${aBeatOut}
		#
		break
             ;;
             ${options[4]})
		exit
	     ;;
            *) 
                echo invalid option
            ;;
        esac
    done
}
main_menu 
#
# BEATS CONFIG SECTION
#
beats_menu () {
    options=(
	"All Beats - Defaults Enabled"
    "Packetbeat"
	"Metricbeat"
	"Filebeat"
	"Heartbeat"
	"Auditbeat
	"Make like a tree, and leave."
    )
    select option in "${options[@]}"; do
        case $option in
            ${options[0]})
			clear
			echo ""
			echo "All Beats"
			echo ""
			# PACKETBEAT
			echo "###" | ${pBeatOut}
			echo "# INTERFACE CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.interfaces.device: any" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.type: af_packet" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.snaplen: 65535" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.buffer_size_mb: 30" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.with_vlans: true" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# FLOW CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.flows:" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  timeout: 30s" | ${pBeatOut}
			echo "  period: 30s" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PROTOCOL CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.protocols:" | ${pBeatOut}
			echo "- type: icmp" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: amqp" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [5672]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: cassandra" | ${pBeatOut}
			echo "  ports: [9042]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: dhcpv4" | ${pBeatOut}
			echo "  ports: [67, 68]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: dns" | ${pBeatOut}
			echo "  ports: [53]" | ${pBeatOut}
			echo "  include_authorities: true" | ${pBeatOut}
			echo "  include_additionals: true" | ${pBeatOut}
			echo "  send_request:  true" | ${pBeatOut}
			echo "  send_response: true" | ${pBeatOut}
			echo "  transaction_timeout: 10s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: http" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [80, 8080, 8000, 5000, 8002]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: memcache" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [11211]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: mysql" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [3306]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: pgsql" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [5432]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: redis" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [6379]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: thrift" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [9090]" | ${pBeatOut}
			echo "  capture_reply: true" | ${pBeatOut}
			echo "  transaction_timeout: 10s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: mongodb" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [27017]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: nfs" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [2049]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: tls" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [443]" | ${pBeatOut}
			echo "  send_certificates: true" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# MONITORED PROCESSES SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.procs:" | ${pBeatOut}
			echo "  enabled: false" | ${pBeatOut}
			echo "  monitored:" | ${pBeatOut}
			echo "    - process: mysqld" | ${pBeatOut}
			echo "      cmdline_grep: mysqld" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: pgsql" | ${pBeatOut}
			echo "      cmdline_grep: postgres" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: nginx" | ${pBeatOut}
			echo "      cmdline_grep: nginx" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: app" | ${pBeatOut}
			echo "      cmdline_grep: gunicorn" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.ignore_outgoing: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# GENERAL SETTINGS SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "#name: Auto-defined by hostname" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#tags: [\"Takes-Make-It\", \"Easy-To-Group-Servers\"]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "queue:" | ${pBeatOut}
			echo "  mem:" | ${pBeatOut}
			echo "    events: 9996" | ${pBeatOut}
			echo "    flush.min_events: 2048" | ${pBeatOut}
			echo "    flush.timeout: 1s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Sets the maximum number of CPUs that can be executing simultaneously. The default is the number of logical CPUs available in the system." | ${pBeatOut}
			echo "#max_procs:" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PROCESSORS SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PLEASE RETURN AFTER REVIEWING ONBOARDED DATA TO MANUALLY CONFIGURE" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- drop_event:" | ${pBeatOut}
			echo "#    when:" | ${pBeatOut}
			echo "#       equals:" | ${pBeatOut}
			echo "#           http.code: 200" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- rename:" | ${pBeatOut}
			echo "#    fields:" | ${pBeatOut}
			echo "#       - from: \"a\"" | ${pBeatOut}
			echo "#         to: \"b\"" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- dissect:" | ${pBeatOut}
			echo "#    tokenizer: \"%{key1} - %{key2}\"" | ${pBeatOut}
			echo "#    field: \"message\"" | ${pBeatOut}
			echo "#    target_prefix: \"dissect\"" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with metadata from the cloud" | ${pBeatOut}
			echo "# provider about the host machine. It works on EC2, GCE, DigitalOcean," | ${pBeatOut}
			echo "# Tencent Cloud, and Alibaba Cloud. Please come back after confirming" | ${pBeatOut}
			echo "# which cloud provider you will be leveraging." | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- add_cloud_metadata: ~" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with the machine\'s local time zone" | ${pBeatOut}
			echo "# offset from UTC." | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- add_locale:" | ${pBeatOut}
			echo "#    format: offset" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with docker metadata, it matches" | ${pBeatOut}
			echo "# container id from log path available in \`source\` field (by default it expects" | ${pBeatOut}
			echo "# it to be /var/lib/docker/containers/*/*.log)." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_docker_metadata: ~" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example enriches each event with host metadata." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_host_metadata:" | ${pBeatOut}
			echo "#   netinfo.enabled: false" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example enriches each event with process metadata using" | ${pBeatOut}
			echo "# process IDs included in the event." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_process_metadata:" | ${pBeatOut}
			echo "#    match_pids: [\"system.process.ppid\"]" | ${pBeatOut}
			echo "#    target: system.process.parent" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example decodes fields containing JSON strings" | ${pBeatOut}
			echo "# and replaces the strings with valid JSON objects." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- decode_json_fields:" | ${pBeatOut}
			echo "#    fields: [\"field1\", \"field2\", ...]" | ${pBeatOut}
			echo "#    process_array: false" | ${pBeatOut}
			echo "#    max_depth: 1" | ${pBeatOut}
			echo "#    target: \"\"" | ${pBeatOut}
			echo "#    overwrite_keys: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# LOGGING SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "logging.level: info   # Available log levels are: error, warning, info, debug" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Send all logging output to syslog. The default is false." | ${pBeatOut}
			echo "#logging.to_syslog: false" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Send all logging output to Windows Event Logs. The default is false." | ${pBeatOut}
			echo "#logging.to_eventlog: false" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Set to true to log messages in json format." | ${pBeatOut}
			echo "#logging.json: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			# METRICBEAT
			echo "#==========================  Modules configuration ============================"  | ${mBeatOut}
			echo "metricbeat.config.modules:"  | ${mBeatOut}
			echo "  path: /etc/metricbeat/modules.d/*.yml"  | ${mBeatOut}
			echo "  reload.period: 10s"  | ${mBeatOut}
			echo "  reload.enabled: false"  | ${mBeatOut}
			echo "#==========================  Modules configuration ============================"  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${mBeatOut}
			echo "setup.template.settings:"  | ${mBeatOut}
			echo "  index.number_of_shards: 1"  | ${mBeatOut}
			echo "  index.codec: best_compression"  | ${mBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#================================ Processors ====================================="  | ${mBeatOut}
			echo "processors:"  | ${mBeatOut}
			echo "  - add_host_metadata: ~"  | ${mBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${mBeatOut}
			echo "#================================ Processors ====================================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#================================ Logging ====================================="  | ${mBeatOut}
			echo "logging.level: debug"  | ${mBeatOut}
			echo "#================================ Logging ====================================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#============================== Xpack Monitoring ==============================="  | ${mBeatOut}
			echo "#xpack.monitoring.enabled: false"  | ${mBeatOut}
			echo "#xpack.monitoring.elasticsearch:"  | ${mBeatOut}
			echo "#============================== Xpack Monitoring ==============================="  | ${mBeatOut}
			sudo metricbeat modules enable system
			sudo mv /etc/metricbeat/modules.d/system.yml  /etc/metricbeat/modules.d/system.yml.bak
			sudo touch /etc/metricbeat/modules.d/system.yml
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 10s"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - cpu"  | ${mBeatSys}
			echo "    - load"  | ${mBeatSys}
			echo "    - memory"  | ${mBeatSys}
			echo "    - network"  | ${mBeatSys}
			echo "    - process"  | ${mBeatSys}
			echo "    - process_summary"  | ${mBeatSys}
			echo "    - socket_summary"  | ${mBeatSys}
			echo "    - core"  | ${mBeatSys}
			echo "    - diskio"  | ${mBeatSys}
			echo "    - socket"  | ${mBeatSys}
			echo "  process.include_top_n:"  | ${mBeatSys}
			echo "    by_cpu: 5      # include top 5 processes by CPU"  | ${mBeatSys}
			echo "    by_memory: 5   # include top 5 processes by memory"  | ${mBeatSys}
			echo ""  | ${mBeatSys}
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 1m"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - filesystem"  | ${mBeatSys}
			echo "    - fsstat"  | ${mBeatSys}
			echo "  processors:"  | ${mBeatSys}
			echo "  - drop_event.when.regexp:"  | ${mBeatSys}
			echo "      system.filesystem.mount_point: '^/(sys|cgroup|proc|dev|etc|host|lib)($|/)'"  | ${mBeatSys}
			echo ""  | ${mBeatSys}
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 15m"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - uptime"  | ${mBeatSys}
			# FILEBEAT
			syslogProto=$(dialog --title "Syslog Protocol (udp OR tcp)" --backtitle "Syslog Config Section" --inputbox "Syslog Protocol (udp OR tcp):" 8 99 3>&1 1>&2 2>&3 3>&- )
			syslogHost=$(dialog --title "Syslog Host (localhost OR 192.168.0.1)" --backtitle "Syslog Config Section" --inputbox "Syslog Host (localhost OR 192.168.0.1):" 8 99 3>&1 1>&2 2>&3 3>&- )
			syslogPort=$(dialog --title "Syslog Port (Must not conflict with existing used port)" --backtitle "Syslog Config Section" --inputbox "Syslog Port (Must not conflict with existing used port):" 8 99 3>&1 1>&2 2>&3 3>&- )
			#netflowPort=$(dialog --title "Netflow Port (Must not conflict with existing used port)" --backtitle "Netflow Config Section" --inputbox "Netflow Port (Must not conflict with existing used port):" 8 99 3>&1 1>&2 2>&3 3>&- )
			echo "#=========================== Filebeat inputs ============================="  | ${fBeatOut}
			echo "filebeat.inputs:"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ Log input --------------------------------"  | ${fBeatOut}
			echo "- type: log"  | ${fBeatOut}
			echo "  enabled: true"  | ${fBeatOut}
			echo "  paths:"  | ${fBeatOut}
			echo "    - /var/log/*.log"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ Syslog input --------------------------------"  | ${fBeatOut}
			echo "- type: syslog"  | ${fBeatOut}
			echo "  protocol.${syslogProto}:"  | ${fBeatOut}
			echo "    host: \"${syslogHost}:${syslogPort}\""  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ NetFlow input --------------------------------"  | ${fBeatOut}
			echo "#- type: netflow"  | ${fBeatOut}
			echo "#    host: \"${netflowHost}:${netflowPort}\""  | ${fBeatOut}
			echo "#  protocols: [ v5, v9, ipfix ]"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#=========================== Filebeat inputs ============================="  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#================================ Logging ==============================="  | ${fBeatOut}
			echo "logging.level: debug"  | ${fBeatOut}
			echo "#================================ Logging ==============================="  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#==================== Elasticsearch template setting ========================"  | ${fBeatOut}
			echo "setup.template.settings:"  | ${fBeatOut}
			echo "  index.number_of_shards: 1"  | ${fBeatOut}
			echo "  index.codec: best_compression"  | ${fBeatOut}
			echo "#==================== Elasticsearch template setting ========================"  | ${fBeatOut}
			sudo filebeat modules enable system
			sudo mv /etc/filebeat/modules.d/system.yml /etc/filebeat/modules.d/system.yml.bak
			echo "- module: system"  | ${fBeatSys}
			echo "  syslog:"  | ${fBeatSys}
			echo "    enabled: true"  | ${fBeatSys}
			echo "    var.paths: [\"/var/log/messages\"]"  | ${fBeatSys}
			echo ""  | ${fBeatSys}
			echo "  # Authorization logs"  | ${fBeatSys}
			echo "  auth:"  | ${fBeatSys}
			echo "    enabled: true"  | ${fBeatSys}
			echo "    var.paths: [\"/var/log/secure\"]"  | ${fBeatSys}
			# HEARTBEAT
			iHeartHTTP=$(dialog --title "What is the website you wish to check? (e.g. https://google.com OR http://google.com)" --backtitle "Heartbeat HTTP Config Section" --inputbox "What is the website you wish to check? (e.g. https://google.com OR http://google.com):" 8 99 3>&1 1>&2 2>&3 3>&- ) 
			iHeartPING=$(dialog --title "What is the website OR IP you wish to check? (e.g. google.com OR 10.0.0.1)" --backtitle "Heartbeat PING Config Section" --inputbox "What is the website OR IP you wish to check? (e.g. google.com OR 10.0.0.1):" 8 99 3>&1 1>&2 2>&3 3>&- ) 
			echo "############################# Heartbeat ######################################"  | ${hBeatOut}
			echo "heartbeat.config.monitors:"  | ${hBeatOut}
			echo "  path: /etc/heartbeat/heartbeat.yml"  | ${hBeatOut}
			echo "heartbeat.monitors:"  | ${hBeatOut}
			echo "- type: http"  | ${hBeatOut}
			echo "  urls: [\"${iHeartHTTP}\"]"  | ${hBeatOut}
			echo "  schedule: '@every 10s'" | ${hBeatOut}
			echo "  ipv4: true"  | ${hBeatOut}
			echo "  ipv6: true"  | ${hBeatOut}
			echo "  mode: any"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "- type: icmp"  | ${hBeatOut}
			echo "  enabled: true"  | ${hBeatOut}
			echo "  schedule: '*/5 * * * * * *' "  | ${hBeatOut}
			echo "  hosts: [\"${iHeartPING}\"]"  | ${hBeatOut}
			echo "  ipv4: true"  | ${hBeatOut}
			echo "  ipv6: true"  | ${hBeatOut}
			echo "  mode: any"  | ${hBeatOut}
			echo "  timeout: 16s"  | ${hBeatOut}
			echo "  wait: 1s"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "setup.template.settings:"  | ${hBeatOut}
			echo "  index.number_of_shards: 1"  | ${hBeatOut}
			echo "  index.codec: best_compression"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#================================ Processors ==============================="  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "processors:"  | ${hBeatOut}
			echo "  - add_host_metadata: ~"  | ${hBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#================================ Logging =================================="  | ${hBeatOut}
			echo "logging.level: debug"  | ${hBeatOut}
			# Auditbeat
			echo "############################# Auditbeat ######################################"  | ${aBeatOut}
			echo "auditbeat.modules:" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: auditd" | ${aBeatOut}
			echo "  audit_rule_files: [ '${path.config}/audit.rules.d/*.conf' ]" | ${aBeatOut}
			echo "  audit_rules: |" | ${aBeatOut}
			echo "    -a always,exit -F arch=b32 -S all -F key=32bit-abi" | ${aBeatOut}
			echo "    ## Executions." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S execve,execveat -k exec" | ${aBeatOut}
			echo "    ## External access (warning: these can be expensive to audit)." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S accept,bind,connect -F key=external-access" | ${aBeatOut}
			echo "    ## Identity changes." | ${aBeatOut}
			echo "    -w /etc/group -p wa -k identity" | ${aBeatOut}
			echo "    -w /etc/passwd -p wa -k identity" | ${aBeatOut}
			echo "    -w /etc/gshadow -p wa -k identity" | ${aBeatOut}
			echo "    ## Unauthorized access attempts." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -k access" | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -k access" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: file_integrity" | ${aBeatOut}
			echo "  paths:" | ${aBeatOut}
			echo "  - /bin" | ${aBeatOut}
			echo "  - /usr/bin" | ${aBeatOut}
			echo "  - /sbin" | ${aBeatOut}
			echo "  - /usr/sbin" | ${aBeatOut}
			echo "  - /etc" | ${aBeatOut}
			echo "  - /home" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: system" | ${aBeatOut}
			echo "  datasets:" | ${aBeatOut}
			echo "    - host    # General host information, e.g. uptime, IPs" | ${aBeatOut}
			echo "    - login   # User logins, logouts, and system boots." | ${aBeatOut}
			echo "    - package # Installed, updated, and removed packages" | ${aBeatOut}
			echo "    - process # Started and stopped processes" | ${aBeatOut}
			echo "    - socket  # Opened and closed sockets" | ${aBeatOut}
			echo "    - user    # User information" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # How often datasets send state updates with the" | ${aBeatOut}
			echo "  # current state of the system (e.g. all currently" | ${aBeatOut}
			echo "  # running processes, all open sockets)." | ${aBeatOut}
			echo "  state.period: 1h" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # Enabled by default. Auditbeat will read password fields in" | ${aBeatOut}
			echo "  # /etc/passwd and /etc/shadow and store a hash locally to" | ${aBeatOut}
			echo "  # detect any changes." | ${aBeatOut}
			echo "  user.detect_password_changes: true" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # File patterns of the login record files." | ${aBeatOut}
			echo "  login.wtmp_file_pattern: /var/log/wtmp*" | ${aBeatOut}
			echo "  login.btmp_file_pattern: /var/log/btmp*" | ${aBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "setup.template.settings:"  | ${aBeatOut}
			echo "  index.number_of_shards: 1"  | ${aBeatOut}
			echo "  index.codec: best_compression"  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "#================================ Processors ==============================="  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "processors:"  | ${aBeatOut}
			echo "  - add_host_metadata: ~"  | ${aBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "#================================ Logging =================================="  | ${aBeatOut}
			echo "logging.level: debug"  | ${aBeatOut}
			break
			;;
			${options[1]})
			clear
			echo "Packetbeat"
			echo "###" | ${pBeatOut}
			echo "# INTERFACE CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.interfaces.device: any" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.type: af_packet" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.snaplen: 65535" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.buffer_size_mb: 30" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.interfaces.with_vlans: true" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# FLOW CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.flows:" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  timeout: 30s" | ${pBeatOut}
			echo "  period: 30s" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PROTOCOL CONFIG SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.protocols:" | ${pBeatOut}
			echo "- type: icmp" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: amqp" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [5672]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: cassandra" | ${pBeatOut}
			echo "  ports: [9042]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: dhcpv4" | ${pBeatOut}
			echo "  ports: [67, 68]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: dns" | ${pBeatOut}
			echo "  ports: [53]" | ${pBeatOut}
			echo "  include_authorities: true" | ${pBeatOut}
			echo "  include_additionals: true" | ${pBeatOut}
			echo "  send_request:  true" | ${pBeatOut}
			echo "  send_response: true" | ${pBeatOut}
			echo "  transaction_timeout: 10s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: http" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [80, 8080, 8000, 5000, 8002]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: memcache" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [11211]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: mysql" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [3306]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: pgsql" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [5432]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: redis" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [6379]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: thrift" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [9090]" | ${pBeatOut}
			echo "  capture_reply: true" | ${pBeatOut}
			echo "  transaction_timeout: 10s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: mongodb" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [27017]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: nfs" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [2049]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "- type: tls" | ${pBeatOut}
			echo "  enabled: true" | ${pBeatOut}
			echo "  ports: [443]" | ${pBeatOut}
			echo "  send_certificates: true" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# MONITORED PROCESSES SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "packetbeat.procs:" | ${pBeatOut}
			echo "  enabled: false" | ${pBeatOut}
			echo "  monitored:" | ${pBeatOut}
			echo "    - process: mysqld" | ${pBeatOut}
			echo "      cmdline_grep: mysqld" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: pgsql" | ${pBeatOut}
			echo "      cmdline_grep: postgres" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: nginx" | ${pBeatOut}
			echo "      cmdline_grep: nginx" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "    - process: app" | ${pBeatOut}
			echo "      cmdline_grep: gunicorn" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "packetbeat.ignore_outgoing: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# GENERAL SETTINGS SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "#name: Auto-defined by hostname" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#tags: [\"Takes-Make-It", "Easy-To-Group-Servers\"]" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "queue:" | ${pBeatOut}
			echo "  mem:" | ${pBeatOut}
			echo "    events: 9996" | ${pBeatOut}
			echo "    flush.min_events: 2048" | ${pBeatOut}
			echo "    flush.timeout: 1s" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Sets the maximum number of CPUs that can be executing simultaneously. The default is the number of logical CPUs available in the system." | ${pBeatOut}
			echo "#max_procs:" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PROCESSORS SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# PLEASE RETURN AFTER REVIEWING ONBOARDED DATA TO MANUALLY CONFIGURE" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- drop_event:" | ${pBeatOut}
			echo "#    when:" | ${pBeatOut}
			echo "#       equals:" | ${pBeatOut}
			echo "#           http.code: 200" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- rename:" | ${pBeatOut}
			echo "#    fields:" | ${pBeatOut}
			echo "#       - from: \"a\"" | ${pBeatOut}
			echo "#         to: \"b\"" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- dissect:" | ${pBeatOut}
			echo "#    tokenizer: \"%{key1} - %{key2}\"" | ${pBeatOut}
			echo "#    field: \"message\"" | ${pBeatOut}
			echo "#    target_prefix: \"dissect\"" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with metadata from the cloud" | ${pBeatOut}
			echo "# provider about the host machine. It works on EC2, GCE, DigitalOcean," | ${pBeatOut}
			echo "# Tencent Cloud, and Alibaba Cloud. Please come back after confirming" | ${pBeatOut}
			echo "# which cloud provider you will be leveraging." | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- add_cloud_metadata: ~" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with the machine\'s local time zone" | ${pBeatOut}
			echo "# offset from UTC." | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "#- add_locale:" | ${pBeatOut}
			echo "#    format: offset" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# The following example enriches each event with docker metadata, it matches" | ${pBeatOut}
			echo "# container id from log path available in \`source\` field (by default it expects" | ${pBeatOut}
			echo "# it to be /var/lib/docker/containers/*/*.log)." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_docker_metadata: ~" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example enriches each event with host metadata." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_host_metadata:" | ${pBeatOut}
			echo "#   netinfo.enabled: false" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example enriches each event with process metadata using" | ${pBeatOut}
			echo "# process IDs included in the event." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- add_process_metadata:" | ${pBeatOut}
			echo "#    match_pids: [\"system.process.ppid\"]" | ${pBeatOut}
			echo "#    target: system.process.parent" | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "# The following example decodes fields containing JSON strings" | ${pBeatOut}
			echo "# and replaces the strings with valid JSON objects." | ${pBeatOut}
			echo "#" | ${pBeatOut}
			echo "#processors:" | ${pBeatOut}
			echo "#- decode_json_fields:" | ${pBeatOut}
			echo "#    fields: [\"field1\", \"field2\", ...]" | ${pBeatOut}
			echo "#    process_array: false" | ${pBeatOut}
			echo "#    max_depth: 1" | ${pBeatOut}
			echo "#    target: \"\"" | ${pBeatOut}
			echo "#    overwrite_keys: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "# LOGGING SECTION" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			echo "logging.level: info   # Available log levels are: error, warning, info, debug" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Send all logging output to syslog. The default is false." | ${pBeatOut}
			echo "#logging.to_syslog: false" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Send all logging output to Windows Event Logs. The default is false." | ${pBeatOut}
			echo "#logging.to_eventlog: false" | ${pBeatOut}
			echo "" | ${pBeatOut}
			echo "# Set to true to log messages in json format." | ${pBeatOut}
			echo "#logging.json: false" | ${pBeatOut}
			echo "###" | ${pBeatOut}
			break
			;;
			${options[2]})
			clear
			echo "Metricbeat"
			echo "#==========================  Modules configuration ============================"  | ${mBeatOut}
			echo "metricbeat.config.modules:"  | ${mBeatOut}
			echo "  path: /etc/metricbeat/modules.d/*.yml"  | ${mBeatOut}
			echo "  reload.period: 10s"  | ${mBeatOut}
			echo "  reload.enabled: false"  | ${mBeatOut}
			echo "#==========================  Modules configuration ============================"  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${mBeatOut}
			echo "setup.template.settings:"  | ${mBeatOut}
			echo "  index.number_of_shards: 1"  | ${mBeatOut}
			echo "  index.codec: best_compression"  | ${mBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#================================ Processors ====================================="  | ${mBeatOut}
			echo "processors:"  | ${mBeatOut}
			echo "  - add_host_metadata: ~"  | ${mBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${mBeatOut}
			echo "#================================ Processors ====================================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#================================ Logging ====================================="  | ${mBeatOut}
			echo "logging.level: debug"  | ${mBeatOut}
			echo "#================================ Logging ====================================="  | ${mBeatOut}
			echo ""  | ${mBeatOut}
			echo "#============================== Xpack Monitoring ==============================="  | ${mBeatOut}
			echo "#xpack.monitoring.enabled: false"  | ${mBeatOut}
			echo "#xpack.monitoring.elasticsearch:"  | ${mBeatOut}
			echo "#============================== Xpack Monitoring ==============================="  | ${mBeatOut}
			sudo mv /etc/metricbeat/modules.d/system.yml  /etc/metricbeat/modules.d/system.yml.bak
			sudo touch /etc/metricbeat/modules.d/system.yml
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 10s"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - cpu"  | ${mBeatSys}
			echo "    - load"  | ${mBeatSys}
			echo "    - memory"  | ${mBeatSys}
			echo "    - network"  | ${mBeatSys}
			echo "    - process"  | ${mBeatSys}
			echo "    - process_summary"  | ${mBeatSys}
			echo "    - socket_summary"  | ${mBeatSys}
			echo "    - core"  | ${mBeatSys}
			echo "    - diskio"  | ${mBeatSys}
			echo "    - socket"  | ${mBeatSys}
			echo "  process.include_top_n:"  | ${mBeatSys}
			echo "    by_cpu: 5      # include top 5 processes by CPU"  | ${mBeatSys}
			echo "    by_memory: 5   # include top 5 processes by memory"  | ${mBeatSys}
			echo ""  | ${mBeatSys}
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 1m"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - filesystem"  | ${mBeatSys}
			echo "    - fsstat"  | ${mBeatSys}
			echo "  processors:"  | ${mBeatSys}
			echo "  - drop_event.when.regexp:"  | ${mBeatSys}
			echo "      system.filesystem.mount_point: '^/(sys|cgroup|proc|dev|etc|host|lib)($|/)'"  | ${mBeatSys}
			echo ""  | ${mBeatSys}
			echo "- module: system"  | ${mBeatSys}
			echo "  period: 15m"  | ${mBeatSys}
			echo "  metricsets:"  | ${mBeatSys}
			echo "    - uptime"  | ${mBeatSys}
			break
			;;
			${options[3]})
			clear
			echo "Filebeat"
			syslogProto=$(dialog --title "Syslog Protocol (udp OR tcp)" --backtitle "Syslog Config Section" --inputbox "Syslog Protocol (udp OR tcp):" 8 99 3>&1 1>&2 2>&3 3>&- )
			syslogHost=$(dialog --title "Syslog Host (localhost OR 192.168.0.1)" --backtitle "Syslog Config Section" --inputbox "Syslog Host (localhost OR 192.168.0.1):" 8 99 3>&1 1>&2 2>&3 3>&- )
			syslogPort=$(dialog --title "Syslog Port (Must not conflict with existing used port)" --backtitle "Syslog Config Section" --inputbox "Syslog Port (Must not conflict with existing used port):" 8 99 3>&1 1>&2 2>&3 3>&- )
			#netflowPort=$(dialog --title "Netflow Port (Must not conflict with existing used port)" --backtitle "Netflow Config Section" --inputbox "Netflow Port (Must not conflict with existing used port):" 8 99 3>&1 1>&2 2>&3 3>&- )
			echo "#=========================== Filebeat inputs ============================="  | ${fBeatOut}
			echo "filebeat.inputs:"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ Log input --------------------------------"  | ${fBeatOut}
			echo "- type: log"  | ${fBeatOut}
			echo "  enabled: true"  | ${fBeatOut}
			echo "  paths:"  | ${fBeatOut}
			echo "    - /var/log/*.log"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ Syslog input --------------------------------"  | ${fBeatOut}
			echo "- type: syslog"  | ${fBeatOut}
			echo "  protocol.${syslogProto}:"  | ${fBeatOut}
			echo "    host: \"${syslogHost}:${syslogPort}\""  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#------------------------------ NetFlow input --------------------------------"  | ${fBeatOut}
			echo "#- type: netflow"  | ${fBeatOut}
			echo "#    host: \"${netflowHost}:${netflowPort}\""  | ${fBeatOut}
			echo "#  protocols: [ v5, v9, ipfix ]"  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#=========================== Filebeat inputs ============================="  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#================================ Logging ==============================="  | ${fBeatOut}
			echo "logging.level: info"  | ${fBeatOut}
			echo "#================================ Logging ==============================="  | ${fBeatOut}
			echo ""  | ${fBeatOut}
			echo "#==================== Elasticsearch template setting ========================"  | ${fBeatOut}
			echo "setup.template.settings:"  | ${fBeatOut}
			echo "  index.number_of_shards: 1"  | ${fBeatOut}
			echo "  index.codec: best_compression"  | ${fBeatOut}
			echo "#==================== Elasticsearch template setting ========================"  | ${fBeatOut}
			break
			;;
			${options[4]})
			clear
			echo "Hearteat"
			iHeartHTTP=$(dialog --title "What is the website you wish to check? (e.g. https://google.com OR http://google.com)" --backtitle "Heartbeat HTTP Config Section" --inputbox "What is the website you wish to check? (https://google.com OR http://google.com):" 8 99 3>&1 1>&2 2>&3 3>&- ) 
			iHeartPING=$(dialog --title "What is the website OR IP you wish to check? (e.g. google.com OR 10.0.0.1)" --backtitle "Heartbeat PING Config Section" --inputbox "What is the website OR IP you wish to check? (e.g. google.com OR 10.0.0.1):" 8 99 3>&1 1>&2 2>&3 3>&- ) 
			echo "############################# Heartbeat ######################################"  | ${hBeatOut}
			echo "heartbeat.config.monitors:"  | ${hBeatOut}
			echo "  path: /etc/heartbeat/heartbeat.yml"  | ${hBeatOut}
			echo "heartbeat.monitors:"  | ${hBeatOut}
			echo "- type: http"  | ${hBeatOut}
			echo "  urls: [\"${iHeartHTTP}\"]"  | ${hBeatOut}
			echo "  schedule: '@every 10s'" | ${hBeatOut}
			echo "  ipv4: true"  | ${hBeatOut}
			echo "  ipv6: true"  | ${hBeatOut}
			echo "  mode: any"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "- type: icmp"  | ${hBeatOut}
			echo "  enabled: true"  | ${hBeatOut}
			echo "  schedule: '*/5 * * * * * *' "  | ${hBeatOut}
			echo "  hosts: [\"${iHeartPING}\"]"  | ${hBeatOut}
			echo "  ipv4: true"  | ${hBeatOut}
			echo "  ipv6: true"  | ${hBeatOut}
			echo "  mode: any"  | ${hBeatOut}
			echo "  timeout: 16s"  | ${hBeatOut}
			echo "  wait: 1s"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "setup.template.settings:"  | ${hBeatOut}
			echo "  index.number_of_shards: 1"  | ${hBeatOut}
			echo "  index.codec: best_compression"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#================================ Processors ==============================="  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "processors:"  | ${hBeatOut}
			echo "  - add_host_metadata: ~"  | ${hBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${hBeatOut}
			echo ""  | ${hBeatOut}
			echo "#================================ Logging =================================="  | ${hBeatOut}
			echo "logging.level: debug"  | ${hBeatOut}
			break
			;;
			${options[5]})
			# Auditbeat
			echo "############################# Auditbeat ######################################"  | ${aBeatOut}
			echo "auditbeat.modules:" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: auditd" | ${aBeatOut}
			echo "  audit_rule_files: [ '${path.config}/audit.rules.d/*.conf' ]" | ${aBeatOut}
			echo "  audit_rules: |" | ${aBeatOut}
			echo "    -a always,exit -F arch=b32 -S all -F key=32bit-abi" | ${aBeatOut}
			echo "    ## Executions." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S execve,execveat -k exec" | ${aBeatOut}
			echo "    ## External access (warning: these can be expensive to audit)." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S accept,bind,connect -F key=external-access" | ${aBeatOut}
			echo "    ## Identity changes." | ${aBeatOut}
			echo "    -w /etc/group -p wa -k identity" | ${aBeatOut}
			echo "    -w /etc/passwd -p wa -k identity" | ${aBeatOut}
			echo "    -w /etc/gshadow -p wa -k identity" | ${aBeatOut}
			echo "    ## Unauthorized access attempts." | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -k access" | ${aBeatOut}
			echo "    -a always,exit -F arch=b64 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -k access" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: file_integrity" | ${aBeatOut}
			echo "  paths:" | ${aBeatOut}
			echo "  - /bin" | ${aBeatOut}
			echo "  - /usr/bin" | ${aBeatOut}
			echo "  - /sbin" | ${aBeatOut}
			echo "  - /usr/sbin" | ${aBeatOut}
			echo "  - /etc" | ${aBeatOut}
			echo "  - /home" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "- module: system" | ${aBeatOut}
			echo "  datasets:" | ${aBeatOut}
			echo "    - host    # General host information, e.g. uptime, IPs" | ${aBeatOut}
			echo "    - login   # User logins, logouts, and system boots." | ${aBeatOut}
			echo "    - package # Installed, updated, and removed packages" | ${aBeatOut}
			echo "    - process # Started and stopped processes" | ${aBeatOut}
			echo "    - socket  # Opened and closed sockets" | ${aBeatOut}
			echo "    - user    # User information" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # How often datasets send state updates with the" | ${aBeatOut}
			echo "  # current state of the system (e.g. all currently" | ${aBeatOut}
			echo "  # running processes, all open sockets)." | ${aBeatOut}
			echo "  state.period: 1h" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # Enabled by default. Auditbeat will read password fields in" | ${aBeatOut}
			echo "  # /etc/passwd and /etc/shadow and store a hash locally to" | ${aBeatOut}
			echo "  # detect any changes." | ${aBeatOut}
			echo "  user.detect_password_changes: true" | ${aBeatOut}
			echo "" | ${aBeatOut}
			echo "  # File patterns of the login record files." | ${aBeatOut}
			echo "  login.wtmp_file_pattern: /var/log/wtmp*" | ${aBeatOut}
			echo "  login.btmp_file_pattern: /var/log/btmp*" | ${aBeatOut}
			echo "#==================== Elasticsearch template setting =========================="  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "setup.template.settings:"  | ${aBeatOut}
			echo "  index.number_of_shards: 1"  | ${aBeatOut}
			echo "  index.codec: best_compression"  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "#================================ Processors ==============================="  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "processors:"  | ${aBeatOut}
			echo "  - add_host_metadata: ~"  | ${aBeatOut}
			echo "  - add_cloud_metadata: ~"  | ${aBeatOut}
			echo ""  | ${aBeatOut}
			echo "#================================ Logging =================================="  | ${aBeatOut}
			echo "logging.level: debug"  | ${aBeatOut}
			break
			;;
			${options[6]})
			clear
			echo "Make like a tree, and leave."
			exit
			;;
				*)
				echo invalid option
				;;
			esac
		done
		}
	beats_menu
	clear
	echo ""
	echo "Now is the time to setup, start, and enable at boot our Beats"
	echo ""
	read -n 1 -s -r -p "Press any key to continue"
	clear
	ignition_menu () {
    options=(
	"All Beats"
    "Packetbeat Only"
	"Metricbeat Only"
	"Filebeat Only"
	"Heartbeat Only"
	"Auditbeat Only"
	"Make like a tree, and leave."
    )
    select option in "${options[@]}"; do
        case $option in
            ${options[0]})
			clear
			sudo packetbeat setup && sudo service packetbeat start && sudo systemctl enable packetbeat
			sudo metricbeat setup && sudo service metricbeat start && sudo systemctl enable metricbeat
			sudo filebeat setup && sudo service filebeat start && sudo systemctl enable filebeat
			sudo heartbeat setup && sudo service heartbeat-elastic start && sudo systemctl enable heartbeat-elastic
			sudo auditbeat setup && sudo service auditbeat start && sudo systemctl enable auditbeat
			break
			;;
			${options[1]})
			clear
			sudo packetbeat setup && sudo service packetbeat start && sudo systemctl enable packetbeat
			break
			;;
			${options[2]})
			clear
			sudo metricbeat setup && sudo service metricbeat start && sudo systemctl enable metricbeat
			break
			;;
			${options[3]})
			clear
			sudo filebeat setup && sudo service filebeat start && sudo systemctl enable filebeat
			break
			;;
			${options[4]})
			clear
			sudo heartbeat setup && sudo service heartbeat-elastic start && sudo systemctl enable heartbeat-elastic
			break
			;;
			${options[5]})
			sudo auditbeat setup && sudo service auditbeat start && sudo systemctl enable auditbeat
			break
			;;
			${options[6]})
			clear
			echo "Make like a tree, and leave."
			exit
			;;
				*)
				echo invalid option
				;;
			esac
		done
		}
	ignition_menu
esac
done
