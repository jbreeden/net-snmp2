$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::DEBUG

session = Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '2c', :community => 'public')

1.times do |i|
  session.inform(
    oid: '1.3.1.1',
    uptime: 1000,
    varbinds: [
      {oid: '1.3.2.2', value: 'test'}
    ]
  ).print
end
