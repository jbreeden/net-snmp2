$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::INFO

handler = Net::SNMP::TrapHandler.new do
  v1 do
    info 'Got v1 trap'
  end

  v2 do
    info 'Got v2 trap'
  end
end

# If the program gets the interrupt signal, tell the trap handler
# to stop so the program can exit.
trap(:INT) {
  listener.stop
}

handler.listen(162)
