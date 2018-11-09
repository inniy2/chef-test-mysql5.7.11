# # encoding: utf-8

# Inspec test for recipe chef-mysql::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end


# My end goal
# describe command('mysql -uroot -pWhatever_you_said0@ -e \'select \"select version()\"\'') do
    # its('stdout') { should match ('/5.7/') }
# end
sql = mysql_session('root','Whatever_you_said0@','localhost','3306')
describe sql.query('select version() as version') do
    its('stdout') { should match(/5.7/) }
end

# wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
describe file('/usr/local/src/mysql57-community-release-el7-11.noarch.rpm') do
    it { should exist }
end

# sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
describe yum do
    its('mysql57-community/x86_64') { should exist }
end

describe yum.repo('mysql57-community/x86_64') do
    it { should exist }
    it { should be_enabled }
    its('baseurl') { should include '5.7' }
end

# TO DO: Verify it
# yum repolist enabled | grep "mysql.*-community.*"

# SKIP: 
# sudo yum-config-manager --disable mysql56-community

# SKIP: 
# sudo yum-config-manager --enable mysql57-community

# SKIP: 
# vi /etc/yum.repos.d/mysql-community.repo

# sudo yum install mysql-community-server
describe package('mysql-community-server') do
    it { should be_installed }
end

# sudo service mysqld start
describe service ('mysqld') do
    it { should be_enabled }
    it { should be_running }
end


# sudo grep 'temporary password' /var/log/mysqld.log
describe file('/var/log/mysqld.log') do
    it { should exist }
    its('content') { should match /root@localhost:/ }
end

describe port(3306) do
  it { should be_listening }
  its('processes') {should include 'mysqld'}
end

# Create /usr/local/src/get_init_password
#
# #!/bin/bash
# T_PW=""
# string=`cat /var/log/mysqld.log | grep "localhost:"
# for word in $string
# do
#     T_WP=$word
# done
# echo $T_PW > /var/log/init_pw.log
#
# pw=`cat /var/log/init_pw.log`
# 
#
describe file('/usr/local/src/get_init_password') do
    it { should exist }
    its('mode') { should cmp '00755' }
end

# Run /usr/local/src/get_init_password
describe file('/var/log/init_pw.log') do
    it { should exist }
    its('content') { should match(/[a-z]/) }
end

# echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Whatever_you_said'; FLUSH PRIVILEGES " | mysql -uroot -p$pw


# Create /usr/local/src/init_user
describe file('/usr/local/src/init_user') do
    it { should exist }
    its ('content') { should match(/[privileges]/) }
end

# Run /usr/local/src/init_user
sql = mysql_session('root','Whatever_you_said0@','localhost','3306')
describe sql.query('show grants for \'root\'@\'%\' ') do
    its('stdout') { should match(/PRIVILEGES/) }
end
