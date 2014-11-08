module Net::SNMP
  class ManagerRepl
    include Net::SNMP
    attr_accessor :sessions, :pdu
    alias response pdu

    NO_SESSION_PROMPT = <<EOF

No manager sessions active
--------------------------

 - Use `manage(options)` to start a session.
 - run `? manage` for more details

EOF

    def self.start(session=nil)
      pry_context = self.new(session)
      Pry.config.prompt_name = "snmp"
      pry_context.pry
    end

    def initialize(session=nil)
      @sessions = []
      if session
        @sessions << session
      end
    end

    # Adds a session for managing options[:peername] to the sessions list.
    # - Note that all requests are sent to all active sessions, and their
    #   responses are all displayed under their peername.
    # - You may close a session by calling `close(peername)`
    #
    # Arguments
    # - options: A Hash or String object
    #   + As a Hash, accepts the following keys
    #     - peername: ADDRESS_OF_AGENT
    #     - port: PORT (defaults to 161)
    #     - version:  '1'|'2c'|'3' (defaults to '2c')
    #   + As a string, implies the peername, with the version defaulting to '2c'
    #
    # Examples:
    #  manage('192.168.1.5')
    #  manage('192.168.1.5:162')
    #  manage(peername: '192.168.1.5', port: 161, version '2c')
    #  manage(peername: '192.168.1.5:161', version '2c')
    def manage(options)
      options = {:peername => options} if options.kind_of?(String)
      sessions << Session.open(options)
      "Opened session to manage peer: #{options[:peername]}"
    end

    # Close the session with the given `peername`
    #
    # Arguments
    # - peername: May be a string, matching the peername, or an index.
    #   Run the `peer` command to see indexes & peernames for
    #   all active sessions
    #
    # Example:
    #   [7] net-snmp2> peers
    #
    #   Currently Managing
    #   ------------------
    #
    #   [0] localhost:161
    #   [1] localhost:162
    #   [2] localhost:163
    #
    #   => nil
    #   [8] net-snmp2> close 'localhost:163'
    #   => "Closed session for peer: localhost:163"
    #   [9] net-snmp2> close 1
    #   => "Closed session for peer: localhost:162"
    def close(peername)
      case peername
      when Numeric
        index = peername
        if index < (sessions.length)
          session = sessions[index]
          session.close
          sessions.delete(session)
          "Closed session for peer: #{session.peername}"
        else
          "Invalid session index #{index}. Use `peers` to list active sessions."
        end
      when String
        session = sessions.find { |sess| sess.peername.to_s == peername.to_s }
        if (session)
          session.close
          sessions.delete(session)
          "Closed session for peer: #{session.peername}"
        else
          "No session active for '#{peername}'. Use `peers` to list active sessions."
        end
      end
    end

    # List the peers currently being managed
    def peers
      if sessions.count > 0
        puts
        puts "Currently Managing"
        puts "------------------"
        puts
        sessions.each_with_index do |session, i|
          puts "[#{i}] #{session.peername}"
        end
        puts
      else
        puts "No active sessions"
      end
      nil
    end

    # Translates a numerical oid to it's MIB name, or a name to numerical oid
    #
    # Arguments
    # - oid: Either a string, as the numerical OID or MIB variable name,
    #        or an OID object
    def translate(oid)
      MIB.translate(oid)
    end

    # Prints a description of a MIB variable
    #
    # Arguments
    # - oid: May be either a numeric OID, or MIB variable name
    def describe(oid)
      nodes = [MIB[oid]]
      puts ERB.new(Net::SNMP::MIB::Templates::DESCRIBE, nil, "-").result(binding)
    end

    # Prints a description of a the MIB subtree starting at root `oid`
    #
    # Arguments
    # - oid: May be either a numeric OID, or MIB variable name
    def describe_tree(oid)
      root = MIB[oid]
      nodes = [root] + root.descendants.to_a
      puts ERB.new(Net::SNMP::MIB::Templates::DESCRIBE, nil, "-").result(binding)
    end

    # Issue an SNMP GET Request to all active peers
    #
    # Arguments
    # - oids: A single oid, or an array of oids
    def get(oids, options = {})
      each_session do |session|
        @pdu = session.get(oids)
        @pdu.print
        puts "ERROR" if @pdu.error?
      end
      "GET"
    end

    # Issue an SNMP GETNEXT Request to all active peers
    #
    # Arguments
    # - oids: A single oid, or an array of oids
    def get_next(oids, options = {})
      each_session do |session|
        @pdu = session.get_next(oids)
        @pdu.print
        puts "ERROR" if @pdu.error?
      end
      "GETNEXT"
    end

    # Issue an SNMP GETBULK Request to all active peers
    #
    # Arguments
    # - oids: A single oid, or an array of oids
    # - options: A Hash accepting the typical options keys for a request, plus
    #  + non_repeaters: The number of non-repeated oids in the request
    #  + max_repititions: The maximum repititions to return for all repeaters
    # Note that the non-repeating varbinds must be added first.
    def get_bulk(oids, options = {})
      each_session do |session|
        @pdu = session.get_bulk(oids)
        @pdu.print
        puts "ERROR" if @pdu.error?
      end
      "GETBULK"
    end

    # Performs a walk on all active peers for each oid provided
    #
    # Arguments
    # - oids: A single oid, or an array of oids
    def walk(oids, options = {})
      each_session do |session|
        session.walk(oids).each { |oid, value|
          puts "#{MIB.translate(oid)}(#{oid}) = #{value}"
        }
      end
      "WALK"
    end

    # Issue an SNMP Set Request to all active peers
    #
    # Arguments
    # - varbinds: An single varbind, or an array of varbinds, each of which may be
    #   + An Array of length 3 `[oid, type, value]`
    #   + An Array of length 2 `[oid, value]`
    #   + Or a Hash `{oid: oid, type: type, value: value}`
    #     * Hash syntax is the same as supported by PDU.add_varbind
    #     * If type is not supplied, it is infered by the value
    def set(varbinds, options = {})
      each_session do |session|
        @pdu = session.set(varbinds)
        @pdu.print
        puts "ERROR" if @pdu.error?
      end
      "SET"
    end

    private

    def each_session(&block)
      unless sessions.count > 0
        puts NO_SESSION_PROMPT
        raise 'No active session'
      end

      sessions.each_with_index do |session, i|
        name = "#{session.peername}"
        hrule = (['-'] * name.length).join ''
        # Add a blank line before the first result
        puts if i == 0
        puts hrule
        puts name
        puts hrule
        block[session]
        # Add a blank line after each result
        puts
      end

      nil
    end
  end
end
