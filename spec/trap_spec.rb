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
      res.should eq(:success)
    end
  end

  it "should send v2 trap" do
    Net::SNMP::TrapSession.open(:peername => 'localhost:163', :version => '2c') do |sess|
      res = sess.trap_v2(:oid => 'sysContact.0', :uptime => 1000)
      res.should eq(:success)
    end
  end

  it "should send a v2 inform" do
    did_callback = false
    Net::SNMP::TrapSession.open(:peername => 'localhost:163', :version => '2c') do |sess|
      resp = sess.inform(:oid => 'coldStart.0')
      has_cold_start_oid = false
      # Got some weird segfaults when using rspec's ".should include {...}"
      # matcher, so I did this manually.
      resp.varbinds.each do |vb|
        if (vb.oid.to_s == Net::SNMP::MIB.translate('snmpTrapOID.0')) &&
            (vb.value.to_s == Net::SNMP::MIB.translate('coldStart.0'))
          has_cold_start_oid = true
        end
      end
      has_cold_start_oid.should eq(true)
    end
  end
end
