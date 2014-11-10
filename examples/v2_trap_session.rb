$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::DEBUG

puts "Opening session"
session = Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '2c', :community => 'public')

puts "Sending trap"

100000.times do |i|
  puts session.trap_v2(
    oid: '1.3.1.1',
    uptime: 1000
  )
end

sleep 20
