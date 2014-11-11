$: << '../lib'
require 'net-snmp2'

# Initialize SNMP and give it a logger
Net::SNMP.init
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::INFO

agent = Net::SNMP::Agent.new

# If the program gets the interrupt signal, tell the agent
# to stop so the program can exit.
trap(:INT) {
  agent.stop
}

# Using an in-memory Hash to represent our MIB storage
mib = {
  '1.3.1.1' => 1,
  '1.3.1.2' => "I'm a string"
}

# Setting up a provider with a MIB variable name
agent.provide 'sysContact' do
  get do
    reply "Jared Breeden"
  end
end

# The `provide` function creates a provider the Agent can
# delegate to when a request has a varbind that lives under
# the given OID. (Or, for all requests if given `:all`,
# which is the default)
#
# Notes: All get/set handlers are called
# once for each varbind, not once per message. This means
# the agent may call multiple providers to satisfy a single
# message. It also means that the code for iterating over
# a request's varbinds, setting errindex values, etc, is
# encapsulated in the Agent code, and you do not have to
# implement it yourself.
agent.provide '1.3' do

  get do
    # `oid` is provided by the DSL as the OID object for the current varbind
    #
    # Note: The ProviderDsl (in which all agent handlers are run)
    # includes Net::SNMP::Debug, so you can use the info, warn, debug,
    # error, and fatal logging methods.
    info "Got a get request for #{oid}"

    if mib.has_key? oid_str
      # `reply` is provided by the DSL to set the response for the current varbind.
      # For a GetBulk request, you can use it's alias `add`, which is more natural
      # in that context, when you may be setting multiple response varbinds for a
      # single requested OID.
      #
      # `oid_str` is alo provided, and is the same as `oid.to_s`
      reply(mib[oid_str])
    else
      # `no_such_object` can be used to indicate that the variable requested
      # does not exist in the MIB on this machine. See also: `no_such_instance`
      no_such_object
    end
  end

  set do
    info "Get a set request for #{oid} = #{value}"

    # Randomly fail 20% of the time
    if rand > 0.8
      info "Decided to fail... Sending WRONGTYPE errstat"
      # `error` sets the error status of the reply to the given integer.
      # The Agent code handles setting the error index behind the scenes,
      # so you don't have to set it here.
      error Net::SNMP::Constants::SNMP_ERR_WRONGTYPE
      next
    end

    if mib.has_key? oid_str
      # Saving the set value in our MIB storage
      mib[oid_str] = value
      # `ok` copies the current varbind to the response,
      # indicating success to the manager. (Aliased as `echo`)
      ok
    else
      no_such_object
    end
  end

  # Note that the `get_next` handler is also used for varbinds
  # 1..non_repeaters from the request pdu of a get_bulk
  get_next do
    puts "get_next called for #{oid_str}"
    reply(oid: oid_str + '.0', value: 'get_next value')
  end

  # `get_bulk` handler serves all varbinds in a get_bulk request
  # after the non_repeaters have been served by `get_next`
  get_bulk do
    puts "get_bulk called for #{oid_str}"
    (0..max_repetitions).each do |i|
      add(oid: "#{oid_str}.#{i}", value: "Bulk value ##{i}")
    end
  end

end

# Setting up a second provider
# Note: All the OIDs in this example are meaningless.
agent.provide '1.4.1' do
  get do
    reply "Get value from second provider"
  end
end

# Start the agent's run loop, listening to port 161
# Aliases: `run`, `start`
agent.listen(161)
