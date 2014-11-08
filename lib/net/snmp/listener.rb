# Responsibility:
#  - Implements a generic listener for incoming SNMP packets

require 'timeout'
require 'pp'

module Net
module SNMP
  class Listener
    include Debug

    attr_accessor :port, :socket, :packet, :callback

    def initialize
      # Set by `stop` (probably in an INT signal handler) to
      # indicate that the agent should stop
      @killed = false
    end

    def start(port = 161, interval = 2, max_packet_size = 65_000)
      @interval = interval
      @socket = UDPSocket.new
      @socket.bind("127.0.0.1", port)
      @max_packet_size = max_packet_size
      info "Listening on port #{port}"
      run_loop
    end
    alias listen start
    alias run start

    def stop
      @killed = true
    end
    alias kill stop

    def on_message(&block)
      @callback = block
    end

    private

    def run_loop
      packet = nil
      loop {
        begin
          return if @killed
          # TODO: Not exactly the most efficient solution...
          timeout(@interval) do
            @packet = @socket.recvfrom(@max_packet_size)
          end
          return if @killed
          time "Overall Processing Time" do
            message = Message.parse(@packet)
            # `message_received` should be implemented by subclass
            @callback[message, @packet[1][3], @packet[1][1]] if @callback
          end
        rescue Timeout::Error => timeout
          next
        end
      }
    end

  end
end
end
