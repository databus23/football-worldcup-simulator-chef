include_recipe 'apt'
include_recipe 'mysql::server'

#somehow the database::mysql package fails to install the mysql client libs before building the gem
begin
  require 'mysql'
rescue LoadError
  Chef::Log.info "mysql gem not installed. Installing."
  execute "apt-get update" do
    ignore_failure true
    action :nothing
  end.run_action(:run)
  mysql_chef_gem 'default' do
    action :nothing
  end.run_action(:install)
end
include_recipe 'database::mysql'
database_connection = {
  host: node['wmsimulator']['database']['host'],
  port: node['wmsimulator']['database']['port'],
  username: 'root',
  password: node['mysql']['server_root_password']
}
#create database
mysql_database node['wmsimulator']['database']['name'] do
  connection database_connection
  action :create
end

#create user
mysql_database_user node['wmsimulator']['database']['user']  do
  connection database_connection
  password node['wmsimulator']['database']['password']
  host '%'
  action :create
end

#grant permissions
mysql_database_user node['wmsimulator']['database']['user']  do
  connection database_connection
  action :grant
  database_name node['wmsimulator']['database']['name']
  privileges [:all]
end


include_recipe 'redisio::install'
include_recipe 'redisio::enable'
