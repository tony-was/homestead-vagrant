class Homestead
  def Homestead.configure(config, settings)
    # Configure The Box
    config.vm.box = "laravel/homestead"
    config.vm.hostname = "homestead.dev"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

    config.ssh.private_key_path = [ '~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa' ]
    config.ssh.forward_agent = true

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = 'homestead'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Configure Port Forwarding To The Box
    config.vm.network "forwarded_port", guest: 80, host: 8000
    config.vm.network "forwarded_port", guest: 443, host: 44300
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    config.vm.network "forwarded_port", guest: 5432, host: 54320

    # Configure The Public Key For SSH Access
    config.vm.provision "shell" do |s|
      s.inline = "echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
      s.args = [File.read(File.expand_path(settings["authorize"]))]
    end


    # Copy The SSH Private Keys To The Box
    settings["keys"].each do |key|
      config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
        s.args = [File.read(File.expand_path(key)), key.split('/').last]
      end
    end

    # Configure known_hosts On Box
    settings["known_hosts"].each do |host|
      config.vm.provision :shell do |s|
        s.privileged = false
        s.inline = "mkdir -p $1 && touch $2 && ssh-keyscan -H $3 >> $2 && chmod 600 $2"
        s.args = ["/home/vagrant/.ssh", "/home/vagrant/.ssh/known_hosts", host]
      end
    end

    # Register All Of The Configured Shared Folders
    settings["folders"].each do |folder|
      config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
    end

    #Install AU Locale
    config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/locale.sh && bash /vagrant/scripts/wp-cli.sh"
    end

    #Composer self-update
    config.vm.provision "shell" do |s|
      s.inline = "composer self-update > /dev/null 2>&1"
    end

    projects = []
    # Install All The Configured Nginx Sites
    settings["sites"].each do |site|

      projects.push("#{site['name']}.dev")

      args = [site["name"], site["type"]]
      if(site.has_key?("repo"))
        args.push(site["repo"])
      end

      #Set up virutal Server
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/serve.sh $1 $2"
        s.args = args
      end

      #Create database
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/create-mysql.sh $1 "
        s.args = args
      end

      #Pull repository
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/git.sh $1 $2 $3"
        s.args = args
        s.privileged = false
      end

      #Create .env file
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/create-env.sh $1 $2"
        s.args = args
      end

      #Run composer update
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/composer-update.sh $1"
        s.args = args
      end

      #Run npm install
      config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/npm-install.sh $1 $2"
        s.args = [site["name"], site["type"]]
        s.privileged = false
      end

    end

    #Set up hosts file
    config.hostsupdater.aliases = projects

    # Configure All Of The Server Environment Variables
    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
            s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php5/fpm/php-fpm.conf"
            s.args = [var["key"], var["value"]]
        end
      end

      config.vm.provision "shell" do |s|
          s.inline = "service nginx restart && service php5-fpm restart"
      end
    end

    # Update Composer On Every Provision
    #config.vm.provision "shell" do |s|
     # s.inline = "/usr/local/bin/composer self-update"
    #end
  end
end
