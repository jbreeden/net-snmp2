require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'eventmachine'

describe "em" do
  it "should work in event_machine" do
    did_callback = false
    EM.run do
      Net::SNMP::Dispatcher.em_loop

      session = Net::SNMP::Session.open(:peername => 'localhost', :community => 'public') do |s|
        s.get("sysDescr.0") do |op, result|
          did_callback = true
          expect(result.varbinds[0].value).to eq $test_mib['sysDescr.0']
        end
      end

      EM.add_timer(3) do
        expect(did_callback).to eq(true)
        EM.stop
      end
    end
  end
end
