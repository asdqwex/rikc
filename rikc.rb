#!/usr/bin/env ruby

require 'git'
require 'erb'
require 'io/console'
require 'net/http'
require 'net/https'
require 'json'
require 'fileutils'
require "pty"


# Load dotfile to settings
data = File.read(ENV['HOME']+'/.stabby')
config = {}
data.each_line do |line|
  setting = line.split("=")
  config[setting[0].strip] = setting[1].strip
end

# Load stabby modules
Dir["./modules/*.rb"].each {|file| require file }


buffer = ""
prompt = ['RIKC ', 'none', ' > ']
customer_id = ''
# initiate I/O loop
while true
  # print "RIKC customer >"
  print prompt.join()
  # get input
  buffer = STDIN.gets.chomp
  # split input into array
  parts = buffer.split
  # check for use command
  if parts[0] == 'use'
    # set customer ID
    customer_id = parts[1]
    print "customer id set to ", customer_id, "\n"
    # add customer to prompt
    prompt[1] = customer_id
# check if init
  elsif parts[0] == "init" and customer_id != ''
    print "creating customer\n"
    current_customer = Customer.new(customer_id, config)
  # enc execution on "exit"
  elsif buffer == "exit"
    exit
  else
    print "unsupported command\n"
  end
end