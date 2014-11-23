require_relative './spec_helper'

describe "async" do
  context "version 1" do

    describe 'get' do
      it "retrieves scalar values" do
        did_callback = false
        sess = Net::SNMP::Session.open(:peername => 'localhost', port: 161, :community => 'public', version: '2c') do |s|
          s.get(["sysDescr.0", "sysContact.0"]) do |op, pdu|
            did_callback = true
            expect(pdu.varbinds[0].value).to eq($test_mib['sysDescr.0'])
            expect(pdu.varbinds[1].value).to eq($test_mib['sysContact.0'])
          end
        end
        Net::SNMP::Dispatcher.select(false)
        expect(did_callback).to be(true)
      end

      context "when a timeout occurrs" do
        it "calls back with :timeout when a timeout occurrs" do
          did_callback = false
          sess = Net::SNMP::Session.open(:peername => 'www.yahoo.com', :timeout => 1, :retries => 0) do |sess|
            sess.get("sysDescr.0") do |op, pdu|
              did_callback = true
              expect(op).to eql(:timeout)
            end
          end
          sleep 2
          num_ready = sess.select(10)
          expect(num_ready).to eql(0)
          expect(did_callback).to eq(true)
        end
      end
    end

    describe 'get_next'
      it "getnext should work" do
        did_callback = false
        Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', version: '2c') do |s|
          s.get_next(["sysDescr", "sysContact"]) do |op, pdu|
            did_callback = true
            expect(pdu.varbinds[0].value).to eq $test_mib['sysDescr.0']
            expect(pdu.varbinds[1].value).to eq $test_mib['sysContact.0']
          end
        end
        Net::SNMP::Dispatcher.select(false)
        expect(did_callback).to be(true)
      end
    end

  context "version 2" do
    it "get should work" do
      did_callback = false
      Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', :version => '2c') do |s|
        s.get(["sysDescr.0", "sysContact.0"]) do |op, pdu|
          did_callback = true
          expect(pdu.varbinds[0].value).to eq $test_mib['sysDescr.0']
          expect(pdu.varbinds[1].value).to eq $test_mib['sysContact.0']
        end
      end
      Net::SNMP::Dispatcher.select(false)
      expect(did_callback).to be(true)
    end

    it "getnext should work" do
      did_callback = false
      Net::SNMP::Session.open(:peername => 'localhost', :community => 'public', :version => '2c') do |s|
        s.get_next(["sysDescr", "sysContact"]) do |op, pdu|
          did_callback = true
          expect(pdu.varbinds[0].value).to eq $test_mib['sysDescr.0']
          expect(pdu.varbinds[1].value).to eq $test_mib['sysContact.0']
        end
      end
      Net::SNMP::Dispatcher.select(false)
      expect(did_callback).to be(true)
    end

  end

  # context "version 3" do
  #   #failing intermittently
  #   it "should get async using snmpv3" do
  #     did_callback = false
  #     Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #         sess.get(["sysDescr.0"]) do |op, pdu|
  #           did_callback = true
  #           expect(pdu.varbinds[0].value).to eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         end
  #         sleep(0.5)
  #         Net::SNMP::Dispatcher.select(false)
  #         #Net::SNMP::Dispatcher.select(false)
  #         #puts "done select"
  #         expect(did_callback).to be(true)
  #     end
  #   end
  #
  #   it "get should work" do
  #     did_callback = false
  #     sess = Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #       sess.get(["sysDescr.0", "sysContact.0"]) do |op,pdu|
  #         did_callback = true
  #         expect(pdu.varbinds[0].value).to eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         expect(pdu.varbinds[1].value).to eql("Root <root@localhost> (configure /etc/snmp/snmp.local.conf)")
  #       end
  #     end
  #     Net::SNMP::Dispatcher.select(false)
  #     sess.close
  #     expect(did_callback).to be(true)
  #   end
  #
  #   #  XXX  occasionally segfaulting
  #   it "getnext should work" do
  #     did_callback = false
  #
  #     sess = Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User',:security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #       sess.get_next(["sysDescr", "sysContact"]) do |op, pdu|
  #         did_callback = true
  #         expect(pdu.varbinds[0].value).to eql("Linux nmsworker-devel 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64")
  #         expect(pdu.varbinds[1].value).to eql("Root <root@localhost> (configure /etc/snmp/snmp.local.conf)")
  #       end
  #     end
  #     Net::SNMP::Dispatcher.select(false)
  #     sess.close
  #     expect(did_callback).to be(true)
  #   end
  #end
end
