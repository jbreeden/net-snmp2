module Net
  module SNMP
    class TrapSession < Session
      # == Represents a session for sending SNMP traps

      # Options
      #
      # - peername: The address where the trap will be sent
      # - port:     The port where the trap will be sent (default = 162)
      def initialize(options = {})
        # Unless the port was supplied in the peername...
        unless options[:peername][":"]
          # ...default to standard trap port
          options[:port] ||= 162
        end

        super(options)
      end

      # Send an SNMPv1 trap
      #
      # Options
      #
      # - enterprise:    The Oid of the enterprise
      # - trap_type:     The generic trap type.
      # - specific_type: The specific trap type
      # - uptime:        The uptime for this agent
      def trap(options = {})
        pdu = build_v1_trap_pdu(options)
        send_pdu(pdu)
      end

      # Send an SNMPv2 trap
      #
      # Options
      #
      # - oid:    The OID of the inform
      # - uptime: Integer indicating the uptime of this agent
      #
      # TODO: You can only send v1 traps on a v1 session, and same for v2.
      # So, we could always have the client call `trap` and just do the right
      # thing based on the session.
      def trap_v2(options = {})
        pdu = build_v2_trap_pdu(Constants::SNMP_MSG_TRAP2, options)
        send_pdu(pdu)
      end

      # Send an SNMPv2 inform
      #
      # Options
      #
      # - oid:      The OID of the inform
      # - uptime:   Integer indicating the uptime of this agent
      # - varbinds: An array of hashes, like those used for PDU#add_varbind
      def inform(options = {})
        pdu = build_v2_trap_pdu(Constants::SNMP_MSG_INFORM, options)
        response = send_pdu(pdu)
        if response.kind_of?(PDU)
          response.free # Always free the response PDU
          :success # If Session#send_pdu didn't raise, we succeeded
        else
          # If the result was other than a PDU, that's a problem
          raise "Unexpected response type for inform: #{response.class}"
        end
      end

      private

      def send_pdu(pdu)
        result = super(pdu)
        if pdu.command == Constants::SNMP_MSG_INFORM
          pdu.free_own_memory
        else
          pdu.free
        end
        result
      end

      def build_v1_trap_pdu(options = {})
        pdu = PDU.new(Constants::SNMP_MSG_TRAP)
        options[:enterprise] ||= '1.3.6.1.4.1.3.1.1'
        pdu.enterprise = OID.new(options[:enterprise].to_s)
        pdu.trap_type = options[:trap_type].to_i || 1  # need to check all these defaults
        pdu.specific_type = options[:specific_type].to_i || 0
        pdu.time = options[:uptime].to_i || 1
        pdu.agent_addr = options[:agent_addr] || '127.0.0.1'
        if options[:varbinds]
          options[:varbinds].each do |vb|
            pdu.add_varbind(vb)
          end
        end
        pdu
      end

      def build_v2_trap_pdu(pdu_type, options = {})
        if options[:oid].kind_of?(String)
          options[:oid] = Net::SNMP::OID.new(options[:oid])
        end
        options[:uptime] ||= 1

        pdu = PDU.new(pdu_type)
        pdu.add_varbind(:oid => OID.new('sysUpTime.0'), :type => Constants::ASN_TIMETICKS, :value => options[:uptime].to_i)
        pdu.add_varbind(:oid => OID.new('snmpTrapOID.0'), :type => Constants::ASN_OBJECT_ID, :value => options[:oid])
        if options[:varbinds]
          options[:varbinds].each do |vb|
            pdu.add_varbind(vb)
          end
        end
        pdu
      end

    end
  end
end
