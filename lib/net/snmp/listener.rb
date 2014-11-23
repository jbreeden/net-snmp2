require 'timeout'

module Net::SNMP

# Implements a generic listener for incoming SNMP packets

  class Listener
    include Debug

    attr_accessor :port, :socket, :packet, :callback

    def initialize
      # Set by `stop` (probably in an INT signal handler) to
      # indicate that the agent should stop
      @killed = false
    end

    # Starts the listener's run loop
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

    # Stops the listener's run loop
    def stop
      @killed = true
    end
    alias kill stop

    # Sets the handler for all incoming messages.
    #
    # The block provided will be called back for each message as follows:
    #
    #   block[message]
    #
    # Where
    #
    # - `message` is the parsed Net::SNMP::Message object
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
          time "Message Processing" do
            message = Message.parse(@packet)
            @callback[message] if @callback
          end
        rescue Timeout::Error => timeout
          next
        rescue StandardError => ex
          error "Error in listener.\n#{ex}\n  #{ex.backtrace.join("\n  ")}"
        end
      }
    end

  end
end
