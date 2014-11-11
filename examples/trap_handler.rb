$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::INFO

handler = Net::SNMP::TrapHandler.new do
  v1 do
    info <<-EOF


    Got V1 Trap
    -----------

    Enterprise OID: #{enterprise}
    Trap Type: #{general_trap_type}
    Specific Type: #{specific_trap_type}
    Agent Address: #{agent_address}
    Uptime: #{uptime}
    Varbinds: #{varbinds.map {|vb| "#{vb.oid.label}(#{vb.oid}) = #{vb.value}"}.join(', ')}
    EOF
  end

  v2 do
    info <<-EOF


    Got V2 Trap
    -----------

    Trap OID: #{trap_oid}
    Uptime: #{uptime}
    Varbinds: #{varbinds.map {|vb| "#{vb.oid.label}(#{vb.oid}) = #{vb.value}"}.join(', ')}
    EOF
  end

  inform do
    info <<-EOF


    Got Inform
    ----------

    Trap OID: #{trap_oid}
    Uptime: #{uptime}
    Varbinds: #{varbinds.map {|vb| "#{vb.oid.label}(#{vb.oid}) = #{vb.value}"}.join(', ')}
    EOF

    ok
  end
end

# If the program gets the interrupt signal, tell the trap handler
# to stop so the program can exit.
trap(:INT) {
  handler.stop
}

handler.listen(162)
