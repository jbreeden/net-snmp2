require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# TODO
# Need to work on the traps/informs

describe Net::SNMP::TrapSession do
  # it "should send a v1 trap" do
  #   #pending "still working on it"
  #   Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '1', :community => 'public') do |sess|
  #     res = sess.trap
  #     res.should eq(true)
  #   end
  # end

  # it "should send a v2 inform" do
  #   did_callback = false
  #   Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '2c') do |sess|
  #     resp = sess.inform(:oid => 'coldStart.0')
  #   end
  #   did_callback.should be_true
  # end

  it "should send v2 trap" do
    Net::SNMP::TrapSession.open(:peername => 'localhost', :version => '2c') do |sess|
      res = sess.trap_v2(:oid => 'sysContact.0', :value => "testing")
      puts res
    end
  end
end
