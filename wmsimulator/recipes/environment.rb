credentials = data_bag_item('wm-simulator', 'credentials')
node.override['mysql']['server_root_password']        = credentials['mysql']['server_root_password']
node.override['mysql']['server_debian_password']      = credentials['mysql']['server_debian_password']
node.override['wmsimulator']['admin_password']        = credentials['wmsimulator']['admin_password']
node.override['wmsimulator']['session_key']           = credentials['wmsimulator']['session_key']
node.override['wmsimulator']['google_analytics_code'] = credentials['wmsimulator']['google_analytics_code']
node.override['wmsimulator']['database']['password']  = credentials['wmsimulator']['database']['password']
node.override['wmsimulator']['redis']['password']     = credentials['wmsimulator']['redis']['password'] if credentials['wmsimulator']['redis']['password']

if node.recipes.include?('wmsimulator::database')
  node.override['wmsimulator']['database']['host'] = 'localhost'
else
  node.override['wmsimulator']['database']['host']     = search(:node, 'recipes:wmsimulator\:\:database').first.fqdn
  node.override['wmsimulator']['redis']['host']        = node['wmsimulator']['database']['host']
end
node.override['redisio']['servers'] = [port: 6379, requirepass: node['wmsimulator']['redis']['password'] ] if node['wmsimulator']['redis']['password']

