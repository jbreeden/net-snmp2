module Net::SNMP
  class V2InformDsl < V2TrapDsl
    include Debug

    attr_accessor :response

    def initialize(message)
      super
    end

    def ok
      self.response = Message.response_pdu_for(message)
    end

  end
end
