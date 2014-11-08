$: << '../lib'

require 'net-snmp2'
t_start = Time.now
pdu = nil
#Net::SNMP.init # Uncomment this to go real slow
Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |session|
  pdu = session.get(["1.3.6.1.4.1.290.6.7.3.1.3.6.0", '1.3.6.1.4.1.290.6.7.3.1.3.7.0'])
end
t_end = Time.now
puts "Got #{pdu.varbinds[0].value} & #{pdu.varbinds[1].value} in #{(t_end - t_start) * 1000} ms"
