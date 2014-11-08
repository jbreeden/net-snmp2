# Responsibility:
#  - Manages the request/response cycle for incoming messages
#    + Listens for incoming requests
#    + Parses request packets into Message objects
#    + Dispatches the messages to (sub) Agents
#    + Serializes the response from the subagents and sends it to the caller

module Net
module SNMP

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

  def provide(oid = :all, &block)
    # Need a trailing dot on the oid so we can avoid
    # considering 1.3.22 a child of 1.3.2
    oid = (oid.to_sym == :all || oid.end_with?('.')) ? oid : "#{oid}."
    provider = Provider.new(oid)
    provider.instance_eval(&block)

    # Providers are pushed onto the end of the provider queue.
    # When dispatching, this is searched in order for a match.
    # So, like exception handlers, you such specify providers
    # in order of most -> least specific oid. ('1.3.1' comes before '1.3')
    providers << provider
  end

  private

  def process_message(message, from_address, from_port)
    response_pdu = RequestDispatcher.dispatch(message, providers)
    if response_pdu
      Session.open(peername: from_address, port: from_port, version: message.version_name) do |sess|
        sess.send_pdu response_pdu
      end
    end
  end

end
end
end
