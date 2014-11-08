require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Net::SNMP::MIB do
  describe '::translate' do
    it "translates OIDs to variable names including instance indexes" do
      expect(Net::SNMP::MIB.translate('sysContact.0')).to eql '1.3.6.1.2.1.1.4.0'
    end

    it "translates variable names to OIDs including instance indexes" do
      expect(Net::SNMP::MIB.translate('1.3.6.1.2.1.1.4.0')).to eql 'sysContact.0'
    end
  end

  describe '::[]' do
    it "can retrieve MIB nodes by variable name" do
      node = Net::SNMP::MIB["sysDescr"]
      node.label.should eq("sysDescr")
    end

    it "can retrieve MIB nodes by numeric oid" do
      node = Net::SNMP::MIB["1.3.6.1.2.1.1.1"]
      node.label.should eq("sysDescr")
    end
  end
end

describe Net::SNMP::MIB::Node do
  describe "::get_node" do
    it "retrieves MIB nodes by variable name" do
      node = Net::SNMP::MIB::Node.get_node("sysDescr")
      node.label.should eq("sysDescr")
    end

    it "retrieves MIB nodes by numeric oid" do
      node = Net::SNMP::MIB::Node.get_node("1.3.6.1.2.1.1.1")
      node.label.should eq("sysDescr")
    end
  end

  describe "#parent" do
    it "links to the parent node" do
      node = Net::SNMP::MIB::Node.get_node("sysDescr")
      node.parent.label.should eq("system")
    end
  end

  describe "#children" do
    it "contains Node objects for all child nodes" do
      node = Net::SNMP::MIB::Node.get_node("ifTable")
      if_entry = node.children.first
      if_entry.children.should include { |n| n.label == "ifIndex" }
    end
  end

  describe "#siblings" do
    it "contains an array of sibling nodes" do
      node = Net::SNMP::MIB::Node.get_node("sysDescr")
      node.siblings.should include { |n| n.label == "sysName" }
    end
  end

  describe "#oid" do
    it "is an OID object for the node" do
      node = Net::SNMP::MIB::Node.get_node("sysDescr")
      node.oid.to_s.should eq("1.3.6.1.2.1.1.1")
    end
  end
end
