module Net
  module SNMP
    #  Wrapper around netsnmp_pdu.
    class PDU
      extend Forwardable
      include Net::SNMP::Debug
      attr_accessor :struct, :varbinds, :callback, :command
      def_delegators :struct, :pointer

      # Create a new PDU object.
      # +pdu_type+  The type of the PDU.  For example, Net::SNMP::SNMP_MSG_GET.  See constants.rb
      def initialize(pdu_type)
        @varbinds = []
        case pdu_type
        when FFI::Pointer
          @struct = Wrapper::SnmpPdu.new(pdu_type)
          @command = @struct.command
          v = @struct.variables
          unless v.null?
            @varbinds << Varbind.from_pointer(v)
            while( !(v = v.next_variable).null? )
              @varbinds << Varbind.from_pointer(v)
            end
          end
        when Fixnum
          @struct = Wrapper.snmp_pdu_create(pdu_type)
          @command = pdu_type
        else
          raise Error.new, "invalid pdu type"
        end
      end

      # Specifies the number of non-repeating, regular objects at the start of
      # the variable list in the request.
      # (For getbulk requests only, non-repeaters is stored in errstat location)
      def non_repeaters
        @struct.errstat
      end

      def non_repeaters=(nr)
        @struct.errstat = nr
      end

      # The number of iterations in the table to be read for the repeating
      # objects that follow the non-repeating objects.
      # (For getbulk requests only, max-repititions are stored in errindex location)
      def max_repetitions=(mr)
        @struct.errindex = mr
      end

      def max_repetitions
        @struct.errindex
      end

      # Sets the enterprise OID of this PDU
      # (Valid for SNMPv1 traps only)
      def enterprise=(oid)
        @i_own_enterprise = true
        oid = OID.new(oid) if oid.kind_of?(String)
        @struct.enterprise = FFI::LibC.calloc(oid.length, OID.oid_size)
        oid.write_to_buffer(@struct.enterprise)
        @struct.enterprise_length = oid.length
      end

      # The enterprise OID of this PDU
      # (Valid for SNMPv1 traps only)
      def enterprise
        OID.from_pointer(@struct.enterprise, @struct.enterprise_length)
      end

      # Sets the address of the agent that sent this PDU
      # (Valid for SNMPv1 traps only)
      def agent_addr=(addr)
        # @struct.agent_addr is a binary array of 4 characters,
        # so pack the provided string into four bytes and we can assign it
        @struct.agent_addr = addr.split('.').map{ |octet| octet.to_i }.pack("CCCC")
      end

      # The address of the agent that sent this PDU
      # (Valid for SNMPv1 traps only)
      def agent_addr
        # @struct.agent_addr is a binary array of 4 characters,
        # to_a converts this to a ruby array of Integers, then join get's us
        # back to the string form
        @struct.agent_addr.to_a.join('.')
      end

      # The uptime for the PDU
      # (Only valid for SNMPv1 traps)
      def uptime
        @struct.time
      end

      # The uptime for the PDU
      # (Only valid for SNMPv1 traps)
      def uptime=(value)
        @struct.time = value.to_i
      end

      # Returns true if pdu is in error
      def error?
        self.errstat != 0
      end

      # Sets the pdu errstat
      def error=(value)
        @struct.errstat = value
      end
      alias errstat= error=
      alias error_status= error=

      # Sets the error index
      def error_index=(index)
        @struct.errindex = index
      end
      alias errindex= error_index=

      # A descriptive error message
      def error_message
        Wrapper::snmp_errstring(self.errstat)
      end

      # Tries to delegate missing methods to the underlying Wrapper::SnmpPdu object.
      # If it does not respond to the method, calls super.
      def method_missing(m, *args)
        if @struct.respond_to?(m)
          @struct.send(m, *args)
        else
          super
        end
      end

      # Adds a variable binding to the pdu.
      # Options:
      # * +oid+ The SNMP OID
      # * +type+ The data type.  Possible values include Net::SNMP::ASN_OCTET_STR, Net::SNMP::ASN_COUNTER, etc.  See constants.rb
      # * +value+  The value of the varbind.  default is nil.
      def add_varbind(options)
        options[:type] ||= case options[:value]
          when String
            Constants::ASN_OCTET_STR
          when Fixnum
            Constants::ASN_INTEGER
          when Net::SNMP::OID
            Constants::ASN_OBJECT_ID
          when nil
            Constants::ASN_NULL
          else
            raise "Unknown value type"
        end

        value = options[:value]
        value_len = case options[:type]
        when Constants::ASN_NULL,
            Constants::SNMP_NOSUCHOBJECT,
            Constants::SNMP_NOSUCHINSTANCE,
            Constants::SNMP_ENDOFMIBVIEW
          0
        else
          options[:value].size
        end

        value = case options[:type]
          when Constants::ASN_INTEGER,
              Constants::ASN_GAUGE,
              Constants::ASN_COUNTER,
              Constants::ASN_TIMETICKS,
              Constants::ASN_UNSIGNED
            new_val = FFI::MemoryPointer.new(:long)
            new_val.write_long(value)
            new_val
          when Constants::ASN_OCTET_STR,
              Constants::ASN_BIT_STR,
              Constants::ASN_OPAQUE
            value
          when Constants::ASN_IPADDRESS
            # TODO
          when Constants::ASN_OBJECT_ID
            value.pointer
          when Constants::ASN_NULL,
              Constants::SNMP_NOSUCHOBJECT,
              Constants::SNMP_NOSUCHINSTANCE,
              Constants::SNMP_ENDOFMIBVIEW
            nil
          else
            if value.respond_to?(:pointer)
              value.pointer
            else
              raise Net::SNMP::Error.new, "Unknown variable type #{options[:type]}"
            end
        end

        oid = options[:oid].kind_of?(OID) ? options[:oid] : OID.new(options[:oid])
        var_ptr = Wrapper.snmp_pdu_add_variable(@struct.pointer, oid.pointer, oid.length_pointer.read_int, options[:type], value, value_len)
        varbind = Varbind.new(var_ptr)
        varbinds << varbind
      end

      def print_errors
        puts "errstat = #{self.errstat}, index = #{self.errindex}, message = #{self.error_message}"
      end

      # Free the pdu
      # Segfaults at the moment - most of the time, anyway.
      # This is troublesome...
      def free
        # HACK
        # snmp_free_pdu segfaults intermittently when freeing the enterprise
        # oid if we've allocated it. Can't figure out why. For now, freeing it manually
        # before calling snmp_free_pdu does the trick
        if @i_own_enterprise
          FFI::LibC.free @struct.enterprise unless @struct.enterprise.null?
          @struct.enterprise = FFI::Pointer::NULL
        end
        Wrapper.snmp_free_pdu(@struct.pointer)
      end

      def print
        puts "PDU"
        if command == Constants::SNMP_MSG_TRAP
            puts " - Enterprise: #{enterprise}"
            puts " - Trap Type: #{trap_type}"
            puts " - Specific Type: #{specific_type}"
            puts " - Agent Addr: #{agent_addr}"
        end

        puts " - Varbinds:"
        varbinds.each do |v|
          puts "   + #{MIB.translate(v.oid.to_s)}(#{v.oid}) = #{v.value}"
        end
      end

    end
  end
end
