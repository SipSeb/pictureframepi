#!/usr/bin/env ruby

require 'net/imap'
require 'mail'
require "fileutils"
require "date"
require "base64"
require "mini_magick"
require 'optparse'
require 'yaml'
require 'ostruct'

CONFIG_PATH = "/home/pi/.config/mailfetcher"

# Read config
config = YAML.load(File.read("#{CONFIG_PATH}/config.yml"))

DESTINATION_FOLDER = "/home/pi/Pictures"

$options = OpenStruct.new
$options.verbose = false
$options.all = false

def parse_options
  OptionParser.new do |opt|
    opt.on('-v', '--verbose') { |o| $options.verbose = true }
    opt.on('-a', '--all') { |o| $options.all = true }
  end.parse!
end

parse_options()

imap = Net::IMAP.new(config['mailbox']['host'], config['mailbox']['port'].to_i, config['mailbox']['use_ssl'])
if $options.verbose
  puts "Connected to mail server."
end

imap.login(config['mailbox']['username'], config['mailbox']['password'])
if $options.verbose
  puts "Logged in."
end

imap.select(config['mailbox_folder'])
if $options.verbose
  puts "Mailbox selected"
end

imap_search = ["UNSEEN"]
if $options.all === true
  imap_search = ["ALL"]
end

messages_found = 0
imap.search(imap_search).each do |message_id|
  messages_found += 1
  there_were_errors = false
  envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
  puts "From address: #{envelope.from[0].mailbox}@#{envelope.from[0].host}"
  maildate = DateTime.parse(envelope.date)
  puts "Found Mail from '#{envelope.from[0].name} <#{envelope.from[0].mailbox}@#{envelope.from[0].host}>' - Subject '#{envelope.subject}' - date '#{envelope.date}'"
  body = imap.fetch(message_id, "BODY[]")[0].attr["BODY[]"]
  mail = Mail.new(body)
  attachments_found = 0
  mail.attachments.each do |a|
    attachments_found += 1
    next unless a.mime_type =~ /^image\//
    puts "Found Attachment with type #{a.mime_type}, name #{a.filename}"
    begin
      destinationFileName = "/#{maildate.strftime('%Y-%m-%d_%H:%M')}_#{attachments_found}_#{a.filename}"
      File.write("/tmp/" + destinationFileName, a.body.decoded)
      puts "Wrote image to /tmp"
      # Now resize
      image = MiniMagick::Image.open("/tmp/" + destinationFileName)
      image.resize config['screen_resolution']
      image.format "jpg"
      image.write DESTINATION_FOLDER + '/' + destinationFileName
      puts "Wrote image to #{DESTINATION_FOLDER}/#{destinationFileName}."          
      File.chmod(0644, DESTINATION_FOLDER + '/' + destinationFileName)
      File.delete("/tmp/" + destinationFileName)
    rescue Exception => e
      puts "Could not write file to disk: #{e}"
      there_were_errors = true
    end
  end
  unless there_were_errors === true
    imap.store(message_id, "+FLAGS", [:Seen])
    puts "Marked message as read." if $options.verbose
  else
    imap.store(message_id, "-FLAGS", [:Seen])
    puts "There were errors, marked message as unread." if $options.verbose
  end
end
if messages_found == 0
  puts "No new messages found."
end