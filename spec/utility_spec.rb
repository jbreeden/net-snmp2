require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Net::SNMP::Utility do
  it "should compare oids" do
    expect(Net::SNMP::Utility.oid_lex_cmp('1.3.5', '1.3.7')).to eql(-1)
    expect(Net::SNMP::Utility.oid_lex_cmp('1.3.7', '1.3.5')).to eql(1)
    expect(Net::SNMP::Utility.oid_lex_cmp('1.3.7', '1.3.7.1')).to eql(-1)
    expect(Net::SNMP::Utility.oid_lex_cmp('1.3.5', '1.3.5')).to eql(0)
  end
end
