require_relative "./spec_helper"

include Net::SNMP
include Net::SNMP::Debug

$test_agent = Agent.new

$test_agent.provide do
  get do
    # raise "I don't feel like talking..."
    if $test_mib.has_key? variable
      info "Got #{variable} = #{$test_mib[variable]}"
      reply $test_mib[variable]
    else
      no_such_object
    end
  end
end

$test_agent.start
