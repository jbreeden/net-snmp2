require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "synchronous calls" do
  context "version 1" do
    it "get should succeed" do
      Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |sess|
        result = sess.get("sysDescr.0")
        expect(result.varbinds.first.value).to eql($test_mib['sysDescr.0'])
      end
    end

    it "multiple calls within session should succeed" do
      Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |sess|
        result = sess.get("sysDescr.0")
        expect(result.varbinds.first.value).to eql($test_mib['sysDescr.0'])
        second = sess.get("sysName.0")
        expect(second.varbinds.first.value).to eql($test_mib["sysName.0"])
      end
    end

    it "get should succeed with multiple oids" do
      Net::SNMP::Session.open(:peername => "localhost", :community => 'public' ) do |sess|
        result = sess.get(["sysDescr.0", "sysName.0"])
        expect(result.varbinds[0].value).to eql($test_mib['sysDescr.0'])
        expect(result.varbinds[1].value).to eql($test_mib["sysName.0"])
      end
    end

    it "set should succeed" do
      Net::SNMP::Session.open(:peername => 'localhost', :version => 1, :community => 'private') do |sess|
        result = sess.set([['sysContact.0', Net::SNMP::Constants::ASN_OCTET_STR, 'newContact']])
        expect(result.varbinds.first.value).to match(/newContact/)
      end
    end

    it "getnext should succeed" do
      Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |sess|
        result = sess.get_next(["sysUpTimeInstance.0"])
        expect(result.varbinds.first.oid.oid).to eq Net::SNMP::MIB.translate('sysContact.0')
        expect(result.varbinds.first.value).to eq $test_mib['sysContact.0']
      end
    end

    it "getbulk should succeed" do
      Net::SNMP::Session.open(:peername => "localhost" , :version => '2c', :community => 'public') do |sess|
        result = sess.get_bulk(["sysContact.0"], :max_repetitions => 10)
        expect(result.varbinds.first.oid.name).to eql("1.3.6.1.2.1.1.5.0")
        expect(result.varbinds.first.value).to eql($test_mib["sysName.0"])
      end
    end

    it "getbulk should succeed with multiple oids" do
      Net::SNMP::Session.open(:peername => "localhost" , :version => '2c', :community => 'public') do |sess|
        result = sess.get_bulk(["ifIndex", "ifType"], :max_repetitions =>3)
        expect(result.varbinds.size).to eql(6)
      end
    end

    it "rasises an when a non-existant MIB variable is requested" do
      Net::SNMP::Session.open(:peername => "localhost", :community => "public" ) do |sess|
        expect { sess.get(["XXXsysDescr.0"]) }.to raise_error
      end
    end

    it "get_table should work" do
      session = Net::SNMP::Session.open(:peername => "localhost", :version => '1')
      table = session.table("ifEntry")
      expect(table['1']['ifIndex']).to eql(1)
      expect(table['2']['ifIndex']).to eql(2)
    end

    it "walk should work" do
      session = Net::SNMP::Session.open(:peername => 'localhost', :version => 1, :community => 'public')
      results = session.walk("system")
      expect(results[Net::SNMP::MIB.translate('sysDescr.0')]).to eq($test_mib["sysDescr.0"])
    end

    it "walk should work with multiple oids" do
      Net::SNMP::Session.open(:peername => 'localhost', :version => 1) do |sess|
        sess.walk(['system', 'ifTable']) do |results|
          expect(results[Net::SNMP::MIB.translate('sysContact.0')]).to eq $test_mib['sysContact.0']
          expect(results[Net::SNMP::MIB.translate("ifIndex.2")]).to eql(2)
        end
      end
    end

    it "get_columns should work" do
      Net::SNMP::Session.open(:peername => 'localhost') do |sess|
        table = sess.columns(['ifIndex', 'ifDescr', 'ifType'])
        expect(table['1']['ifIndex']).to eql(1)
      end
    end

    it "get a value with oid type should work" do
      Net::SNMP::Session.open(:peername => 'localhost', :community => 'public') do |sess|
        res = sess.get("sysObjectID.0")
        expect(res.varbinds.first.value.to_s).to eq $test_mib['sysObjectID.0'].to_s
      end
    end
  end

  # context "version 3" do
  #   it "should get using snmpv3" do
  #     pending
  #     Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'MD5User', :security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHNOPRIV, :auth_protocol => :md5, :password => 'The Net-SNMP Demo Password') do |sess|
  #       result = sess.get("sysDescr.0")
  #       expect(result.varbinds.first.value).to eql($test_mib['sysDescr.0'])
  #     end
  #   end
  #   it "should set using snmpv3" do
  #     pending
  #     Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'myuser', :auth_protocol => :sha1, :password => '0x1234') do |sess|
  #       result = sess.set([["sysDescr.0", Net::SNMP::Constants::ASN_OCTET_STR, 'yomama']])
  #       expect(result.varbinds.first.value).to match(/Darwin/)
  #     end
  #   end
  #
  #   it "should get using authpriv" do
  #     pending
  #     Net::SNMP::Session.open(:peername => 'localhost', :version => 3, :username => 'mixtli', :security_level => Net::SNMP::Constants::SNMP_SEC_LEVEL_AUTHPRIV, :auth_protocol => :md5, :priv_protocol => :des, :auth_password => 'testauth', :priv_password => 'testpass') do |sess|
  #       result = sess.get("sysDescr.0")
  #       expect(result.varbinds.first.value).to match(/xenu/)
  #     end
  #   end
  # end
end
