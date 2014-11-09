module Net::SNMP
  class V1TrapDsl
    include Debug

    attr_accessor :message

    def initialize(message)
      @message = message
    end

    def pdu
      message.pdu
    end

    def enterprise
      pdu.enterprise
    end
    alias enterprise_oid enterprise

    def trap_type
      pdu.trap_type
    end
    alias general_trap_type trap_type

    def specific_type
      pdu.specific_type
    end
    alias specific_trap_type specific_type

    def agent_addr
      pdu.agent_addr
    end
    alias agent_address agent_addr

    def uptime
      pdu.uptime
    end

    def varbinds
      pdu.varbinds
    end

  end
end
