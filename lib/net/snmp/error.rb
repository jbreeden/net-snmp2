module Net
  module SNMP
    class Error < RuntimeError
      include Debug

      attr_accessor :status, :errno, :snmp_err, :snmp_msg
      def initialize(opts = {})
        @status = opts[:status]
        @fiber = opts[:fiber]
        if opts[:session]
          @errno = opts[:session].errno
          @snmp_err = opts[:session].snmp_err
          @snmp_msg = opts[:session].error_message
        end
        print
      end

      def print
        message = <<-EOF

        SNMP Error: #{self.class.to_s}
        message = #{message}
        status = #{@status}
        errno = #{@errno}
        snmp_err = #{@snmp_err}
        snmp_msg = #{@snmp_msg}
        EOF

        error(message.gsub /^\s*/, '')
      end
    end

    class TimeoutError < Error
    end
  end
end
