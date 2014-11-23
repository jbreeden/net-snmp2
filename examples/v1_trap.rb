$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::DEBUG

session = Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '1', :community => 'public')

100000.times do |i|
  puts "#{i + 1}: " + session.trap(
    enterprise: '1.3.1',
    trap_type: 6,
    specific_type: 1,
    uptime: 1000,
    agent_addr: '127.0.0.1'
  ).to_s
end
