module Net::SNMP
  class V2TrapDsl
    include Debug

    attr_accessor :message

    def initialize(message)
      @message = message
    end

    def pdu
      message.pdu
    end

    def oid
      vb = varbinds.find{|vb| vb.oid.to_s == Constants::OID_SNMP_TRAP_OID}
      if vb
        vb.value
      else
        nil
      end
    end
    alias trap_oid oid

    def uptime
      vb = varbinds.find{|vb| vb.oid.to_s == Constants::OID_SYS_UP_TIME_INSTANCE}
      if vb
        vb.value
      else
        nil
      end
    end

    def varbinds
      pdu.varbinds
    end
  end
end
