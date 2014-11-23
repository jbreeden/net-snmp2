require_relative "./spec_helper"

include Net::SNMP
include Net::SNMP::Debug

$test_agent = Agent.new

$test_agent.provide do
  get do
    info "GET #{variable}"
    if $test_mib.has_key? variable
      reply $test_mib[variable]
    else
      info "No such object"
      no_such_object
    end
  end

  get_next do
    info "GETNEXT #{variable}"
    # TODO: Get rid of this nasty case statement (Use the mib to determine the next value)
    case variable
    when 'system'
      reply oid: 'sysDescr.0', value: $test_mib['sysDescr.0']
    when 'sysDescr'
      reply oid: 'sysDescr.0', value: $test_mib['sysDescr.0']
    when 'sysDescr.0'
      reply oid: 'sysUpTimeInstance.0', value: $test_mib['sysUpTimeInstance.0']
    when 'sysUpTimeInstance.0'
      reply oid: 'sysContact.0', value: $test_mib['sysContact.0']
    when 'sysContact'
      reply oid: 'sysContact.0', value: $test_mib['sysContact.0']
    when 'sysContact.0'
      reply oid: 'sysName.0', value: $test_mib['sysName.0']
    when 'ifTable'
      reply oid: 'ifSpecific.1', value: 1
    when 'ifSpecific'
      reply oid: 'ifSpecific.1', value: 'stub'
    when 'ifSpecific.1'
      reply oid: 'ifOutQLen.1', value: 'stub'
    when 'ifOutQLen'
      reply oid: 'ifOutQLen.1', value: 'stub'
    when 'ifOutQLen.1'
      reply oid: 'ifOutErrors.1', value: 'stub'
    when 'ifOutErrors'
      reply oid: 'ifOutErrors.1', value: 'stub'
    when 'ifOutErrors.1'
      reply oid: 'ifOutDiscards.1', value: 'stub'
    when 'ifOutDiscards'
      reply oid: 'ifOutDiscards.1', value: 'stub'
    when 'ifOutDiscards.1'
      reply oid: 'ifOutNUcastPkts.1', value: 'stub'
    when 'ifOutNUcastPkts'
      reply oid: 'ifOutNUcastPkts.1', value: 'stub'
    when 'ifOutNUcastPkts.1'
      reply oid: 'ifOutUcastPkts.1', value: 'stub'
    when 'ifOutUcastPkts'
      reply oid: 'ifOutUcastPkts.1', value: 'stub'
    when 'ifOutUcastPkts.1'
      reply oid: 'ifOutOctets.1', value: 'stub'
    when 'ifOutOctets'
      reply oid: 'ifOutOctets.1', value: 'stub'
    when 'ifOutOctets.1'
      reply oid: 'ifInUnknownProtos.1', value: 'stub'
    when 'ifInUnknownProtos'
      reply oid: 'ifInUnknownProtos.1', value: 'stub'
    when 'ifInUnknownProtos.1'
      reply oid: 'ifInErrors.1', value: 'stub'
    when 'ifInErrors'
      reply oid: 'ifInErrors.1', value: 'stub'
    when 'ifInErrors.1'
      reply oid: 'ifInDiscards.1', value: 'stub'
    when 'ifInDiscards'
      reply oid: 'ifInDiscards.1', value: 'stub'
    when 'ifInDiscards.1'
      reply oid: 'ifInNUcastPkts.1', value: 'stub'
    when 'ifInNUcastPkts'
      reply oid: 'ifInNUcastPkts.1', value: 'stub'
    when 'ifInNUcastPkts.1'
      reply oid: 'ifInUcastPkts.1', value: 'stub'
    when 'ifInUcastPkts'
      reply oid: 'ifInUcastPkts.1', value: 'stub'
    when 'ifInUcastPkts.1'
      reply oid: 'ifInOctets.1', value: 'stub'
    when 'ifInOctets'
      reply oid: 'ifInOctets.1', value: 'stub'
    when 'ifInOctets.1'
      reply oid: 'ifLastChange.1', value: 'stub'
    when 'ifLastChange'
      reply oid: 'ifLastChange.1', value: 'stub'
    when 'ifLastChange.1'
      reply oid: 'ifOperStatus.1', value: 'stub'
    when 'ifOperStatus'
      reply oid: 'ifOperStatus.1', value: 'stub'
    when 'ifOperStatus.1'
      reply oid: 'ifAdminStatus.1', value: 'stub'
    when 'ifAdminStatus'
      reply oid: 'ifAdminStatus.1', value: 'stub'
    when 'ifAdminStatus.1'
      reply oid: 'ifPhysAddress.1', value: 'stub'
    when 'ifPhysAddress'
      reply oid: 'ifPhysAddress.1', value: 'stub'
    when 'ifPhysAddress.1'
      reply oid: 'ifSpeed.1', value: 'stub'
    when 'ifSpeed'
      reply oid: 'ifSpeed.1', value: 'stub'
    when 'ifSpeed.1'
      reply oid: 'ifMtu.1', value: 'stub'
    when 'ifMtu'
      reply oid: 'ifMtu.1', value: 'stub'
    when 'ifMtu.1'
      reply oid: 'ifType.1', value: 'stub'
    when 'ifType'
      reply oid: 'ifType.1', value: 'stub'
    when 'ifType.1'
      reply oid: 'ifDescr.1', value: 'stub'
    when 'ifDescr'
      reply oid: 'ifDescr.1', value: 'stub'
    when 'ifDescr.1'
      reply oid: 'ifIndex.1', value: 1
    when 'ifIndex'
      reply oid: 'ifIndex.1', value: 1
    when 'ifIndex.1'
      reply oid: 'ifIndex.2', value: 2
    else
      end_of_mib
    end
  end

  get_bulk do
    info "GETBULK #{variable}"
    case variable
    when 'sysContact.0'
      add oid: 'sysName.0', value: $test_mib['sysName.0']
    else
      max_repetitions.times do
        echo
      end
    end
  end

  set do
    info "SET #{variable} = #{value}"
    # Not actually going to set the variable in $test_mib
    # so that the tests don't depend on each other.
    ok
  end
end

$test_agent.start
