require 'bundler'
require 'pry'
Bundler::GemHelper.install_tasks

task :console do
  require 'pry'
  require 'logger'
  $: << 'lib'
  require 'net-snmp2'
  Net::SNMP::Debug.logger = Logger.new(STDOUT)
  Net::SNMP::Debug.logger.level = Logger::INFO
  include Net::SNMP
  ARGV.clear

  current_prompt = nil
  Pry.config.prompt = [
    proc { |obj, level|
      current_prompt = "[net-snmp2 (#{obj}) (#{level})] "
    }, proc {
      "[#{'.' * (current_prompt.length - 3)}] "
    }
  ]
  Net::SNMP.pry
end
