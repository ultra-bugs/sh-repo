#!/bin/bash
echo "Apache2 debian based site configuration utility."
# Ask for subdomain name
read -p "Enter domain name: " subdomain

# Ask for directory name
read -p "Enter directory name: " directory

# Function to validate and ask for PHP version
get_php_version() {
    while true; do
        read -p "Choose PHP version to use (Default, 7.4, 8.0, 8.1, 8.2): " php_version
        case $php_version in
            "Default"|"7.4"|"8.0"|"8.1"|"8.2")
                break ;;
            *)
                read -p "Invalid choice. Do you want to choose again? (y/n): " choice
                if [[ "$choice" != "y" ]]; then
                    echo "Aborted. No changes made."
                    exit 1
                fi ;;
        esac
    done
}

# Ask for PHP version to use
get_php_version

# Check if configuration file already exists
if [[ -f "$config_file" ]]; then
    echo "Configuration file already exists:"
    cat "$config_file"
    read -p "Do you want to overwrite the existing file? (y/n): " overwrite
    if [[ "$overwrite" != "y" ]]; then
        echo "Aborted. No changes made."
        exit 1
    fi
fi

# Set ROOT and SITE variables
ROOT="/var/www/${directory}"
SITE="${subdomain}"

# Create configuration file
config_file="/etc/apache2/sites-available/${subdomain}.conf"
echo "define ROOT \"${ROOT}\"" > $config_file
echo "define SITE \"${SITE}\"" >> $config_file
echo "" >> $config_file
echo '<VirtualHost *:80>' >> $config_file
echo "    DocumentRoot \"\${ROOT}\"" >> $config_file
echo "    ServerName \${SITE}" >> $config_file
echo "    SetEnv isNoFollow true" >> $config_file
echo "    <Directory \"\${ROOT}\">" >> $config_file
echo "        AllowOverride All" >> $config_file
echo "        Require all granted" >> $config_file
echo "    </Directory>" >> $config_file
echo "    ErrorLog \${APACHE_LOG_DIR}/error-\${SITE}.log" >> $config_file
echo "    CustomLog \${APACHE_LOG_DIR}/access-\${SITE}.log combined" >> $config_file
if [[ "$php_version" != "Default" ]]; then
    echo "    Include \"/etc/apache2/conf-available/php${php_version}-fpm.conf\"" >> $config_file
fi
echo "    RewriteEngine on" >> $config_file
echo "    RewriteCond %{SERVER_NAME} =\${SITE}" >> $config_file
echo "    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]" >> $config_file
echo "</VirtualHost>" >> $config_file
echo "" >> $config_file
echo '<VirtualHost *:443>' >> $config_file
echo "    DocumentRoot \"\${ROOT}\"" >> $config_file
echo "    ServerName \${SITE}" >> $config_file
echo "    SetEnv isNoFollow true" >> $config_file
echo "    <Directory \"\${ROOT}\">" >> $config_file
echo "        AllowOverride All" >> $config_file
echo "        Require all granted" >> $config_file
echo "    </Directory>" >> $config_file
echo "    ErrorLog \${APACHE_LOG_DIR}/error-\${SITE}.log" >> $config_file
echo "    CustomLog \${APACHE_LOG_DIR}/access-\${SITE}.log combined" >> $config_file
if [[ "$php_version" != "Default" ]]; then
    echo "    Include \"/etc/apache2/conf-available/php${php_version}-fpm.conf\"" >> $config_file
fi
echo "    Include /etc/letsencrypt/options-ssl-apache.conf" >> $config_file
echo "    SSLCertificateFile /etc/letsencrypt/live/zuko.pro/fullchain.pem" >> $config_file
echo "    SSLCertificateKeyFile /etc/letsencrypt/live/zuko.pro/privkey.pem" >> $config_file
echo "</VirtualHost>" >> $config_file

# Display success message and restart Apache
echo "Configuration file created successfully: ${config_file}"
echo "Config file content"
echo "================================================================================================"
echo ""
echo ""
echo ""
cat $config_file
echo ""
echo ""
echo ""
echo "================================================================================================"
echo Enabling site ${subdomain}
a2ensite $subdomain
echo "Restarting Apache to apply changes..."
sudo systemctl restart apache2
