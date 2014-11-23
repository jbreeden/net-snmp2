require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Net::SNMP::OID do
  it "should instantiate valid oid with numeric" do
    oid = Net::SNMP::OID.new("1.3.6.1.2.1.2.1.0")
    expect(oid.to_s).to eql("1.3.6.1.2.1.2.1.0")
    expect(oid.label).to eql("ifNumber.0")
  end

  it "should instantiate valid oid with string" do
    oid = Net::SNMP::OID.new("ifNumber.0")
    expect(oid.to_s).to eql("1.3.6.1.2.1.2.1.0")
    expect(oid.label).to eql("ifNumber.0")
  end

  it "should to_s correctly" do
    oid_str = "1.3.6.1.2.1.2.1.0"
    oid = Net::SNMP::OID.new(oid_str)
    expect(oid.to_s).to eq(oid_str)
  end
end
