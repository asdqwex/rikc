#!/usr/bin/env ruby

require 'git'
require 'erb'
require 'io/console'
require 'net/http'
require 'net/https'
require 'json'
require 'fileutils'
require "pty"

# Workflow
#   - ./rick
#   - RIKC none > help
#   - RIKC none > create 1234-customer
#   - RIKC none > use 1234-customer
#   - RIKC 1234-customer > list servers
#   - RIKC 1234-customer > list environments
#   - RIKC 1234-customer > list databags
#   - RIKC 1234-customer > list cookbooks
#   - RIKC 1234-customer > show server servername
#   - RIKC 1234-customer > show environment environmentname
#   - RIKC 1234-customer > show databag databagname
#   - RIKC 1234-customer > show cookbook cookbookname

# Load dotfile to settings
data = File.read(ENV['HOME']+'/.rikc')
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

  #   - RIKC none > help
  if parts[0] == 'help'
    puts %q(
      Workflow
        - ./rick
        - RIKC none > help
        - RIKC none > create 1234-customer
        - RIKC none > use 1234-customer
        - RIKC 1234-customer > list servers
        - RIKC 1234-customer > list environments
        - RIKC 1234-customer > list databags
        - RIKC 1234-customer > list cookbooks
        - RIKC 1234-customer > show server servername
        - RIKC 1234-customer > show environment environmentname
        - RIKC 1234-customer > show databag databagname
        - RIKC 1234-customer > show cookbook cookbookname
    )

  #   - RIKC none > create 1234-customer
  elsif parts[0] == 'create'
    print "creating customer\n"
    current_customer = Customer.new(customer_id, config)

  #   - RIKC none > use 1234-customer
  elsif parts[0] == 'use'
    # set customer ID
    customer_id = parts[1]
    print "customer id set to ", customer_id, "\n"
    # add customer to prompt
    prompt[1] = customer_id

  elsif parts[0] == 'list'

  elsif parts[0] == 'show'

  # end execution on "exit"
  elsif buffer == 'exit'
    exit
  else
    print "unsupported command\n"
  end
end
