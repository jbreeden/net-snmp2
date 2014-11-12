module Net
module SNMP
class Message
  include SNMP::Debug

  def self.parse(packet)
    Message.new(packet)
  end

  attr_accessor :version,
    :community,
    :pdu,
    :version_ptr,
    :community_ptr,
    :source_address,
    :source_port

  def version_name
    case @version
    when Constants::SNMP_VERSION_1
      '1'
    when Constants::SNMP_VERSION_2c
      '2c'
    when Constants::SNMP_VERSION_3
      '3'
    else
      raise "Invalid SNMP version: #{@version}"
    end
  end

  def initialize(packet)
    @version = nil
    @version_ptr = FFI::MemoryPointer.new(:long, 1)
    @community_ptr = FFI::MemoryPointer.new(:uchar, 100)
    @packet = packet
    @packet_length = packet[0].length
    @type_ptr = FFI::MemoryPointer.new(:int, 1)
    @data_ptr = FFI::MemoryPointer.new(:char, @packet_length)
    @data_ptr.write_bytes(packet[0])
    @cursor_ptr = @data_ptr
    @bytes_remaining_ptr = FFI::MemoryPointer.new(:int, 1)
    @bytes_remaining_ptr.write_bytes([@packet_length].pack("L"))
    @source_address = @packet[1][3]
    @source_port = @packet[1][1]
    debug "MESSAGE INITIALIZED\n#{self}"
    parse
  end

  # Sends the given PDU back to the origin of this message.
  # The origin is the same address and port that the message was
  # received from.
  def respond(response_pdu)
    Session.open(peername: source_address, port: source_port, version: version_name) do |sess|
      sess.send_pdu(response_pdu)
    end
  end

  # Sends a response PDU to the source of the message with all of the same
  # varbinds. (Useful for sets & informs, where this is how you indicate success)
  def echo
    response_pdu = make_response_pdu
    pdu.varbinds.each do |vb|
      response_pdu.add_varbind(oid: vb.oid, type: vb.type, value: vb.value)
    end
    respond(response_pdu)
  end

  # Constructs a PDU for responding to this message.
  # This makes sure the PDU has the right request ID, version,
  # and community set.
  def make_response_pdu
    response_pdu = PDU.new(Constants::SNMP_MSG_RESPONSE)
    response_pdu.reqid = pdu.reqid
    response_pdu.version = version
    response_pdu.community = pdu.community
    response_pdu
  end

  private

  attr_accessor :type,
    :length,
    :data,
    :cursor,
    :bytes_remaining

  def parse
    parse_length
    parse_version
    parse_community
    parse_pdu
    self
  end

  def parse_length
    @cursor_ptr = Net::SNMP::Wrapper.asn_parse_header(@data_ptr, @bytes_remaining_ptr, @type_ptr)
    unless @type_ptr.read_int == 48
      raise "Invalid SNMP packet. Message should start with a sequence declaration"
    end
    debug "MESSAGE SEQUENCE HEADER PARSED\n#{self}"
  end

  def parse_version
    @cursor_ptr = Net::SNMP::Wrapper.asn_parse_int(
      @cursor_ptr,
      @bytes_remaining_ptr,
      @type_ptr,
      @version_ptr,
      @version_ptr.total)

    @version = @version_ptr.read_long
    debug "VERSION NUMBER PARSED\n#{self}"
  end

  def parse_community
    community_length_ptr = FFI::MemoryPointer.new(:size_t, 1)
    community_length_ptr.write_int(@community_ptr.total)
    @cursor_ptr = Net::SNMP::Wrapper.asn_parse_string(
      @cursor_ptr,
      @bytes_remaining_ptr,
      @type_ptr,
      @community_ptr,
      community_length_ptr)

    @community = @community_ptr.read_string
    debug "COMMUNITY PARSED\n#{self}"
  end

  def parse_pdu
    ###########################################
    # Don't do this...
    #
    #    pdu_struct_ptr = Wrapper::SnmpPdu.new
    #
    # We do not want to own this pointer, or we can't call `snmp_free_pdu` on it,
    # which happens in PDU#free. Instead, let the native library allocate it.
    # Note that if we allocate any members for this pdu (like the enterprise oid string),
    # We will have to free those ourselves before calling `snmp_free_pdu`.
    #
    # If the above is not done, segfaults start happening when one side tries
    # to free memory malloc'ed by the other side. Possibly because the netsnmp.dll
    # links to a different C Runtime library, which may have differences in malloc/free.
    pdu_struct_ptr = Wrapper.snmp_pdu_create(0)
    ###########################################

    Net::SNMP::Wrapper.snmp_pdu_parse(pdu_struct_ptr, @cursor_ptr, @bytes_remaining_ptr)
    @pdu = Net::SNMP::PDU.new(pdu_struct_ptr.pointer)
    debug "PDU PARSED\n#{self}"
  end

  def to_s
    <<-EOF
    version(#{@version})
    community(#{@community})
    pdu
      command(#{@pdu.command if @pdu})
      varbinds (#{@pdu.varbinds.map{|v| "\n          #{v.oid.to_s} => #{v.value}" }.join('') if @pdu})
    type(#{@type_ptr.read_int})
    bytes_remaining(#{@bytes_remaining_ptr.read_int})
    cursor @ #{@cursor_ptr.address}
      Byte:  #{indices = []; (@bytes_remaining_ptr.read_int.times {|i| indices.push((i+1).to_s.rjust(2))}; indices.join ' ')}
      Value: #{@cursor_ptr.get_bytes(0, @bytes_remaining_ptr.read_int).each_byte.map {|b| b.to_s(16).rjust(2, '0') }.join(' ')}
    data @ #{@data_ptr.address}
      #{@data_ptr.get_bytes(0, @packet_length).each_byte.map {|b| b.to_s(16).rjust(2, '0') }.join(' ')}
    EOF
  end
end
end
end
