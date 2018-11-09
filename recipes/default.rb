#
# Cookbook:: chef-mysql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
remote_file '/usr/local/src/mysql57-community-release-el7-11.noarch.rpm' do
    source 'https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm'
    action :create
end

# sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
yum_package 'mysql57-community-release-el7-11.noarch.rpm' do
    source '/usr/local/src/mysql57-community-release-el7-11.noarch.rpm'
    action :install
end

# sudo yum install mysql-community-server
yum_package 'mysql-community-server' do
    action :install
end

# sudo service mysqld start
service 'mysqld' do
    action [ :enable, :start ]
end

# Create /usr/local/src/get_init_password
template '/usr/local/src/get_init_password' do
    source 'get_init_password.erb'
    mode '0755'
end

# Run /usr/local/src/get_init_password
execute 'run_the_get_script' do
    command '/usr/local/src/get_init_password'
    action :nothing
    subscribes :run, 'template[/usr/local/src/get_init_password]', :immediate
end

# Run  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Whatever_you_said'; FLUSH PRIVILEGES " | mysql -uroot -p$pw
# mysql -uroot -p`cat /var/log/init_pw.log` -e 'alter user "root"@"localhost" identified by "Whatever_you_said"'
execute 'run_alter_user' do
    command 'echo " alter user root@localhost identified by "\'"Whatever_you_said0@"\' | mysql --connect-expired-password -uroot -p`cat /var/log/init_pw.log`'
    action :nothing
    subscribes :run, 'execute[run_the_get_script]', :delayed
end

# TO-DO: Following scripts are NOT YET tested! Run it first and see what happens!!

# Create /usr/local/src/init_user
template '/usr/local/src/init_user' do
    source 'init_user.erb'
end

# Run  cat /usr/local/src/init_user | mysql -uroot -p"Whatever_you_said0@"
execute 'run_init_user' do
    command 'cat /usr/local/src/init_user | mysql -uroot -pWhatever_you_said0@'
    action :nothing
    subscribes :run, 'template[/usr/local/src/init_user]', :delayed
end
