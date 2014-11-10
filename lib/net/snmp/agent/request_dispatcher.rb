module Net::SNMP

# RequestDispatcher module handles calling all required providers for a request
# in the context of a ProviderDsl object (which itself provides the agent DSL)

  module RequestDispatcher

    def self.dispatch(message, providers)
      response_pdu = Message::response_pdu_for(message)
      context = ProviderDsl.new
      context.message = message
      context.response_pdu = response_pdu
      message.pdu.varbinds.each_with_index do |vb, index|
        context.varbind = vb
        provider = providers.find { |p| p.oid == :all || vb.oid.to_s.start_with?(p.oid.to_s) }
        if provider
          if message.pdu.command == Constants::SNMP_MSG_GETBULK && index < message.pdu.non_repeaters
            handler = provider.handler_for(Constants::SNMP_MSG_GETNEXT)
          else
            handler = provider.handler_for(message)
          end
          if handler
            context.instance_exec(&handler)
          else
            Debug.warn "No handler for command: #{message.pdu.command} @ #{vb.oid}"
            context.no_such_object
          end
        else
          Debug.warn "No provider for oid: #{vb.oid}"
          context.no_such_object
        end
      end

      response_pdu
    end

  end
end
