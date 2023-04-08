#!/usr/bin/env ruby

require 'net/imap'
require 'mail'
require 'yaml'
require 'optparse'
require 'ostruct'


CONFIG_PATH = "/home/pi/.config/mailfetcher"

$options = OpenStruct.new
$options.verbose = false
def parse_options
  OptionParser.new do |opt|
    opt.on('-v', '--verbose') { |o| $options.verbose = true }
  end.parse!
end

parse_options()

# Read config
config = YAML.load_file("#{CONFIG_PATH}/config.yml")

if $options.verbose === true
  Net::IMAP.debug = true
  puts "Will connect to host #{config['mailbox']['host']} port #{config['mailbox']['port']} using username #{config['mailbox']['username']}."
end

imap = Net::IMAP.new(config['mailbox']['host'], config['mailbox']['port'].to_i, config['mailbox']['use_ssl'])
puts "Connected to mail server."

imap.login(config['mailbox']['username'], config['mailbox']['password'])
puts "Logged in."

folder = imap.list("", config['mailbox_folder'])
if folder.nil?
  puts "Error: Specified IMAP folder does not exist"
  exit 1
else
  puts "IMAP folder exists"
  status = imap.status(config['mailbox_folder'], ["MESSAGES", "UNSEEN"])
  puts "Number of messages: #{status['MESSAGES']} - unread: #{status['UNSEEN']}"
end

imap.disconnect
