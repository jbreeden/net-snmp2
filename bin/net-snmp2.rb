require 'irb'
require 'irb/completion'
require 'logger'
$: << "#{File.dirname(__FILE__)}/../lib"
require 'net-snmp2'
Net::SNMP::Debug.logger = Logger.new(STDOUT)
Net::SNMP::Debug.logger.level = Logger::INFO
include Net::SNMP
ARGV.clear
IRB.start
