module Net::SNMP

# Providers are responsible for handling requests for a given subtree
# of the system's MIB. The Provider object itself holds the root OID
# of the subtree provided, and handlers for the various request types.
# The handlers are executed for each varbind of the incoming message
# individually in the context of a ProviderDsl object.
#
# Clients do not create Providers directly. Instead, they call `provide` on
# an Agent, passing in a block. Within the block they use the `get`, `get_next`,
# `get_bulk`, and `set` methods to configure handlers for these request types.
# Within these handlers, the DSL methods from the ProviderDsl class can be
# used to inspect the current request.
#
# Example
#
#     require 'net-snmp2'
#     agent = Net::SNMP::Agent.new
#     agent.provide :all do
#
#       get do
#         reply get_value_somehow(oid)
#       end
#
#       set do
#         reply set_value_somehow(oid)
#       end
#
#       get_next do
#         reply get_next_value_somehow(oid)
#       end
#
#       get_bulk do
#         (0..max_repetitions).each do |i|
#           add get_bulk_vlue_somehow(oid, i)
#         end
#       end
#
#     end
#     agent.listen(161)

  class Provider
    attr_accessor :oid,
      :get_handler,
      :set_handler,
      :get_next_handler,
      :get_bulk_handler

    # Creates a new Provider with `oid` as the root of its subtree
    def initialize(oid)
      if oid.kind_of?(Symbol)
        unless oid == :all
          raise "Cannot provide symbol '#{oid}'. (Did you mean to use :all?)"
        end
        @oid = oid
      else
        # Guarantee OID is in numeric form
        @oid = OID.new(oid).to_s
      end
    end

    # Gets the handler for the given command type from this provider.
    #
    # Arguments
    #
    # - command
    #   + As an integer, specifies the command type a handler is needed for.
    #   + May also be a Message or PDU object, from which the command type is read.
    def handler_for(command)
      # User might be tempted to just pass in the message, or pdu,
      # if so, just pluck the command off of it.
      if command.kind_of?(Message)
        command = command.pdu.command
      elsif command.kind_of?(PDU)
        command = command.command
      end

      case command
      when Constants::SNMP_MSG_GET
        get_handler
      when Constants::SNMP_MSG_GETNEXT
        get_next_handler
      when Constants::SNMP_MSG_GETBULK
        get_bulk_handler
      when Constants::SNMP_MSG_SET
        set_handler
      else
        raise "Invalid command type: #{command}"
      end
    end

    # Returns a boolean indicating whether this provider provides
    # the given `oid`
    def provides?(oid)
      self.oid == :all || oid.to_s =~ %r[#{self.oid.to_s}(\.|$)]
    end

    [:get, :set, :get_next, :get_bulk].each do |request_type|
      self.class_eval %Q[
        def #{request_type}(&proc)
          self.#{request_type}_handler = proc
        end
      ]
    end
  end
end
