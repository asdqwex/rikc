# Module that manages a customer cookbook localy, on github and on the chef server
class Customer
  def initialize(id, config)
    # timestamp
    timestamp = Time.now.strftime("%d-%m-%Y")
    work_dir = config["path"]
    cust_dir = "#{work_dir}/#{id}"
    @cust_id=id
    # Create customer directory structure
    # /home/user/{work_dir}/{customer_id}/
    if File.directory?(cust_dir)
      puts "That customer already exists, not createing directory"
    else
      puts "making custoner dir #{cust_dir}"
      Dir.mkdir cust_dir
    end
    #     \ gitrepo
    if File.directory?("#{cust_dir}/#{id}")
      puts "That customer git repo already exists, not createing directory"
    else
      puts "checking out repo to #{cust_dir}/#{id}"
      g = Git.clone("git@github.com:AutomationSupport/#{id}.git", "#{id}", :path => cust_dir)
    end
    #     \ .chef
    chef_dir = "#{cust_dir}/.chef"
    if File.directory?(chef_dir)
      puts "That customer .chef dir already exists, not createing directory"
    else
      puts "making custoner dir #{chef_dir}"
      Dir.mkdir chef_dir
    end
    #         \ knife.rb
    knife_rb_path = "#{cust_dir}/.chef/knife.rb"
    if File.file?(knife_rb_path)
      puts "That customer knife.rb already exists, not createing directory"
    else
      puts "createing knife.rb #{knife_rb_path}"
      work_dir = config["path"]
      cust_dir = "#{work_dir}/#{id}"
      node_name = "#{config["chef_user"]}"
      client_name = "#{id}"
      rs_api_username = ""
      rs_api_key = ""
      rs_api_endpoint = ""
      data = File.new("knife.rb.erb").read
      template = ERB.new(data)
      File.write(knife_rb_path, template.result())
    end
    #         \ user_pem
    user_pem_path = config["user_pem"]
    if File.file?(user_pem_path)
      puts "your users pem already exists, not createing file"
    else
      File.symlink("#{user_pem_path}", "#{cust_dir}/.chef/")
    end
    #         \ cusomer_validator.pem
    #         \ databag_secret
    if File.file?(ENV['HOME']+"/.stabby-token-#{timestamp}")
      stored_token = File.read(ENV['HOME']+"/.stabby-token-#{timestamp}")
    else
      # Gets user and password for passwordsafe auth
      puts "USERNAME:"
      username = STDIN.gets.chomp
      puts "PIN + RSA:"
      pin = STDIN.noecho(&:gets).chomp
      # puts "authing with username #{username} and pin ********"
      # pull secrets from Passwordsage
      auth_uri = config["cloud_id_uri"].to_s
      # puts "authing with #{config["cloud_id_uri"]}"
      auth_blob = "{\"auth\": {\"RAX-AUTH:domain\": {\"name\": \"Rackspace\"},\"RAX-AUTH:rsaCredentials\": {\"username\": \"#{username}\", \"tokenKey\": \"#{pin}\"}}}"
      uri = URI.parse(auth_uri)
      http = Net::HTTP.new(auth_uri, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new("/v2.0/tokens")
      request.add_field('Content-Type', 'application/json')
      request.body = auth_blob
      response = http.request(request)
      json = JSON.parse(response.body)
      stored_token = json["access"]["token"]["id"]
      File.write(ENV['HOME']+"/.stabby-token-#{timestamp}", "#{stored_token}")
    end
    # puts stored_token
    # load pwdsafe for project ID
    pwdsafe_proj_id = config["pwdsafe_project"]
    # puts pwdsafe_proj_id
    # Search pwdsafe for org validator ID
    pwdsafe = config["password_safe_uri"]
    uri = URI.parse("#{pwdsafe}/projects/#{pwdsafe_proj_id}/credentials.json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    #http.set_debug_output($stdout)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.initialize_http_header({"X-Auth-Token" => "#{stored_token}"})
    response = http.request(request)
    pwdsafe_data = JSON.parse(response.body)
    cust_org_val_key = ''
    cust_dbag_key = ''
    pwdsafe_data.each do |item|
      #puts "===================="
      #puts item["credential"]["description"]
      #puts item["credential"]["category"]
      #puts "===================="
      # Get org validator ID from pwdsafe
      if item["credential"]["description"] == "#{id}" and item["credential"]["category"] == "org validator"
        cust_org_val_key = item["credential"]["password"].to_s
      end
      # Get databag key ID from pwdsafe
      if item["credential"]["description"] == "#{id}" and item["credential"]["category"] == "enc-databag-keys"
        cust_dbag_key = item["credential"]["password"].to_s
      end
    end
    if File.file?("#{cust_dir}/.chef/#{id}-validator.pem")
      puts "That customer pem already exists, not createing file"
    else
      puts "creating customer org pem"
      File.write("#{cust_dir}/.chef/#{id}-validator.pem", cust_org_val_key)
    end
    if File.file?("#{cust_dir}/.chef/encrypted_data_bag_secret")
      puts "That customer databag key already exists, not createing file"
    else
      puts "creating customer databag key"
      File.write("#{cust_dir}/.chef/encrypted_data_bag_secret", cust_dbag_key)
    end
  end
end
