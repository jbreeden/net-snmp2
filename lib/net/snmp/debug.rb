module Net
module SNMP
module Debug
  class << self
    attr_accessor :logger
  end

  [:debug, :info, :warn, :error, :fatal].each do |log_level|
    self.module_eval %Q{
      def #{log_level}(msg = nil, &block)
        if Debug.logger && (Debug.logger.level <= Logger::#{log_level.upcase})
          Debug.logger.send(:#{log_level}, msg)
          block[] if block_given?
        end
      end
    }
  end

  def time(label, &block)
    t_start = Time.now
    block[]
    t_end = Time.now
    info "#{label}: #{(t_end - t_start)*1000}ms"
  end

  def print_packet(packet)
    byte_string = (packet.kind_of?(Array) ? packet[0] : packet)

    byte_array = byte_string.unpack("C*")
    binary =  byte_array.map{|n| n.to_s(2).rjust(8, '0')}

    puts " # | Decimal |  Hex  |  Binary  | Character"
    puts "-------------------------------------------"

    i = 0
    prev = 0
    byte_array.zip(binary).each do |byte, binary_string|
      puts "#{i.to_s.ljust(5)}#{byte.to_s.ljust(10)}0x#{byte.to_s(16).ljust(6)}#{binary_string.ljust(11)}#{byte.chr}   #{'Sequence Length' if byte == 130 && prev == 48}"
      prev = byte
      i += 1
    end
  end
end
end
end
