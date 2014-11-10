$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::DEBUG

puts "Opening session"
session = Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '1', :community => 'public')

puts "Sending trap"

100000.times do |i|
  session.trap(
    enterprise: '1.3.1',
    trap_type: 6,
    specific_type: 1,
    uptime: 1000,
    agent_addr: '127.0.0.1'
  )
end

sleep 20
