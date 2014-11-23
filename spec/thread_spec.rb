require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "in a thread" do
  it "should get an oid asynchronously in a thread" do
    did_callback = false
    dispatch_thread = Net::SNMP::Dispatcher.thread_loop
    Net::SNMP::Session.open(:peername => 'localhost', :community => 'public') do |s|
      s.get(["sysDescr.0", "sysContact.0"]) do |op, result|
        did_callback = true
        expect(result.varbinds[0].value).to eq $test_mib['sysDescr.0']
        expect(result.varbinds[1].value).to eq $test_mib['sysContact.0']
      end
    end
    sleep 3
    expect(did_callback).to be(true)

    Thread.kill(dispatch_thread)
  end
end
