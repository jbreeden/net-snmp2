# RequestDispatcher module handles calling all required providers for a request
# in the context of a RequestContext object (which itself provides the agent DSL)

module Net::SNMP
  module RequestDispatcher

    def self.dispatch(message, providers)
      response_pdu = Message::response_pdu_for(message)
      context = RequestContext.new
      context.message = message
      context.response_pdu = response_pdu
      message.pdu.varbinds.each do |vb|
        context.varbind = vb
        provider = providers.find { |p| p.oid == :all || vb.oid.to_s.start_with?(p.oid.to_s) }
        handler = provider.handler_for(message) if provider
        if handler
          context.instance_exec(&handler)
        else
          Debug.warn "No handler for command: #{message.pdu.command} @ #{vb.oid}"
          context.no_such_object
        end
      end

      response_pdu
    end

  end
end
