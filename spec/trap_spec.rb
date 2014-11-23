require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# NOTE: Run a trap receiver on port 163 for these tests to pass.
# (I'm using MIB Browser's builtin receiver)
# This is just because I'm using the veraxsystem SNMP simulator for other tests,
# and it occupies port 162 but doesn't respond to the informs

describe Net::SNMP::TrapSession do
  it "should send a v1 trap" do
    Net::SNMP::TrapSession.open(:peername => 'localhost:163', :version => '1', :community => 'public') do |sess|
      res = sess.trap(
        enterprise: '1.3.1',
        trap_type: 6,
        specific_type: 1,
        uptime: 1000,
        agent_addr: '127.0.0.1'
      )
      expect(res).to eq(:success)
    end
  end

  it "should send v2 trap" do
    Net::SNMP::TrapSession.open(:peername => 'localhost:163', :version => '2c') do |sess|
      res = sess.trap_v2(:oid => 'sysContact.0', :uptime => 1000)
      expect(res).to eq(:success)
    end
  end

  it "should send a v2 inform" do
    did_callback = false
    Net::SNMP::TrapSession.open(:peername => 'localhost:163', :version => '2c') do |sess|
      resp = sess.inform(:oid => 'coldStart.0')
      expect(resp).to eq(:success)
    end
  end
end
