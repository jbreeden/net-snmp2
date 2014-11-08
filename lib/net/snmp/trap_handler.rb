module Net::SNMP
  class TrapHandler
    include Net::SNMP::Debug
    extend Forwardable

    attr_accessor :listener, :v1_handler, :v2_handler, :trap
    def_delegators :listener, :start, :run, :listen, :stop, :kill

    def self.listen(port = 162, interval = 2, max_packet_size = 65_000, &block)
      self.new
    end

    def initialize(&block)
      @listener = Net::SNMP::Listener.new
      @listener.on_message(&method(:process_trap))
      self.instance_eval(&block)
    end

    private

    def process_trap(message, from_address, from_port)
      self.trap = message
      if message.pdu.command == Net::SNMP::Constants::SNMP_MSG_TRAP
        self.instance_eval(&v1_handler)
      elsif message.pdu.command == Net::SNMP::Constants::SNMP_MSG_TRAP2
        self.instance_eval(&v2_handler)
      end
    end

    def v1(&handler)
      @v1_handler = handler
    end

    def v2(&handler)
      @v2_handler = handler
    end
  end
end
