require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'eventmachine'
require 'fiber'

describe "in fiber" do

  def wrap_fiber
    EM.run do
      Net::SNMP::Dispatcher.fiber_loop
      Fiber.new { yield; EM.stop }.resume(nil)
    end
  end

  it "get should work in a fiber with synchronous calling style" do
    wrap_fiber do
        session = Net::SNMP::Session.open(:peername => 'localhost', :community => 'public')
        result = session.get("sysDescr.0")
        expect(result.varbinds[0].value).to eq $test_mib["sysDescr.0"]
    end
  end

  it "getnext" do
    wrap_fiber do
      Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |sess|
        result = sess.get_next(["sysUpTimeInstance.0"])
        expect(result.varbinds.first.oid.oid).to eq Net::SNMP::MIB.translate('sysContact.0')
        expect(result.varbinds.first.value).to eq $test_mib['sysContact.0']
      end
    end
  end

  it "should get using snmpv3" do
    pending
    wrap_fiber do
      Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User', :security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
        result = sess.get(["sysDescr.0"])
        expect(result.varbinds.first.value).to eq $test_mib["sysDescr.0"]
      end
    end
  end

end
