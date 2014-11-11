module Net::SNMP

# Agents delegate messages from the Net::SNMP::Listener to
# providers, which supply the actual responses to the varbinds
# in the request. See Net::SNMP::ProviderDsl

  class Agent
    include Debug
    extend Forwardable

    attr_accessor :listener, :providers
    def_delegators :listener, :start, :listen, :run, :stop, :kill

    def initialize
      @listener = Net::SNMP::Listener.new
      @providers = []
      @listener.on_message(&method(:process_message))
    end

    # This method is called with a block to define a provider
    # for some subtree of the MIB. When a request comes in with varbinds
    # in that providers subtree, the provider's handlers will be called
    # to generate the varbind to send back in the response PDU.
    #
    # Arguments
    #
    # - oid: The root OID of the MIB subtree this provider is responsible for.
    # - &block: A block, to be instance_evaled on the new Provider.
    def provide(oid = :all, &block)
      provider = Provider.new(oid)
      provider.instance_eval(&block)

      # Providers are pushed onto the end of the provider queue.
      # When dispatching, this is searched in order for a match.
      # So, like exception handlers, you such specify providers
      # in order of most -> least specific oid. ('1.3.1' comes before '1.3')
      providers << provider
    end

    private

    # The callback given to the Listener object for handling an SNMP message.
    # Calls `dispatch`, then sends the response PDU, if one is returned.
    def process_message(message, from_address, from_port)
      response_pdu = dispatch(message)
      if response_pdu
        Session.open(peername: from_address, port: from_port, version: message.version_name) do |sess|
          sess.send_pdu response_pdu
        end
      end
    end

    # Collects responses for the given message from the available providers
    def dispatch(message)
      response_pdu = Message::response_pdu_for(message)
      context = ProviderDsl.new
      context.message = message
      context.response_pdu = response_pdu
      message.pdu.varbinds.each_with_index do |vb, index|
        context.varbind = vb
        provider = providers.find { |p| p.provides?(vb.oid) }
        if provider
          if message.pdu.command == Constants::SNMP_MSG_GETBULK && index < message.pdu.non_repeaters
            handler = provider.handler_for(Constants::SNMP_MSG_GETNEXT)
          else
            handler = provider.handler_for(message)
          end
          if handler
            context.instance_exec(&handler)
          else
            warn "No handler for command: #{message.pdu.command} @ #{vb.oid}"
            context.no_such_object
          end
        else
          warn "No provider for oid: #{vb.oid}"
          context.no_such_object
        end
      end
      response_pdu
    end

  end
end
