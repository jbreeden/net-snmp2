require_relative './spec_helper'
#require_relative './test_agent'

describe "async" do
  context "version 1" do

    describe 'get' do
      it "retrieves scalar values" do
        did_callback = false
        sess = Net::SNMP::Session.open(:peername => 'localhost', port: 161, :community => 'public', version: '2c') do |s|
          s.get(["sysDescr.0", "sysContact.0"]) do |op, pdu|
            did_callback = true
            pdu.print
            pdu.varbinds[0].value.should eq($test_mib['sysDescr.0'])
            pdu.varbinds[1].value.should eq($test_mib['sysContact.0'])
          end
        end
        puts "Calling select"
        Net::SNMP::Dispatcher.select(false)
        did_callback.should be(true)
      end

      context "when a timeout occurrs" do
        it "calls back with :timeout when a timeout occurrs" do
          did_callback = false
          sess = Net::SNMP::Session.open(:peername => 'www.yahoo.com', :timeout => 1, :retries => 0) do |sess|
            sess.get("sysDescr.0") do |op, pdu|
              did_callback = true
              op.should eql(:timeout)
            end
          end
          sleep 2
          pdu = sess.select(10)

          pdu.should eql(0)
          did_callback.should eq(true)
        end
      end
    end

    describe 'get_next'
      it "getnext should work" do
        did_callback = false
        Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', version: '2c') do |s|
          s.get_next(["sysDescr", "sysContact"]) do |op, pdu|
            did_callback = true
            pdu.varbinds[0].value.should eq $test_mib['sysDescr.0']
            pdu.varbinds[1].value.should eq $test_mib['sysContact.0']
          end
        end
        Net::SNMP::Dispatcher.select(false)
        did_callback.should be(true)
      end
    end

  context "version 2" do
    it "get should work" do
      did_callback = false
      Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', :version => '2c') do |s|
        s.get(["sysDescr.0", "sysContact.0"]) do |op, pdu|
          did_callback = true
          pdu.varbinds[0].value.should eq $test_mib['sysDescr.0']
          pdu.varbinds[1].value.should eq $test_mib['sysContact.0']
        end
      end
      Net::SNMP::Dispatcher.select(false)
      did_callback.should be(true)
    end

    it "getnext should work" do
      did_callback = false
      Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', :version => '2c') do |s|
        s.get_next(["sysDescr", "sysContact"]) do |op, pdu|
          did_callback = true
          pdu.varbinds[0].value.should eq $test_agent['sysDescr.0']
          pdu.varbinds[1].value.should eq $test_agent['sysContact.0']
        end
      end
      Net::SNMP::Dispatcher.select(false)
      did_callback.should be(true)
    end

  end

  # context "version 3" do
  #   #failing intermittently
  #   it "should get async using snmpv3" do
  #     did_callback = false
  #     Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #         sess.get(["sysDescr.0"]) do |op, pdu|
  #           did_callback = true
  #           pdu.varbinds[0].value.should eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         end
  #         sleep(0.5)
  #         Net::SNMP::Dispatcher.select(false)
  #         #Net::SNMP::Dispatcher.select(false)
  #         #puts "done select"
  #         did_callback.should be(true)
  #     end
  #   end
  #
  #   it "get should work" do
  #     did_callback = false
  #     sess = Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #       sess.get(["sysDescr.0", "sysContact.0"]) do |op,pdu|
  #         did_callback = true
  #         pdu.varbinds[0].value.should eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         pdu.varbinds[1].value.should eql("Root <root@localhost> (configure /etc/snmp/snmp.local.conf)")
  #       end
  #     end
  #     Net::SNMP::Dispatcher.select(false)
  #     sess.close
  #     did_callback.should be(true)
  #   end
  #
  #   #  XXX  occasionally segfaulting
  #   it "getnext should work" do
  #     did_callback = false
  #
  #     sess = Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #       sess.get_next(["sysDescr", "sysContact"]) do |op, pdu|
  #         did_callback = true
  #         pdu.varbinds[0].value.should eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         pdu.varbinds[1].value.should eql("Root <root@localhost> (configure /etc/snmp/snmp.local.conf)")
  #       end
  #     end
  #     Net::SNMP::Dispatcher.select(false)
  #     sess.close
  #     did_callback.should be(true)
  #   end
  #end
end
