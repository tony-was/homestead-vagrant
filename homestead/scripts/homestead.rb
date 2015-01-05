class Homestead
  def Homestead.configure(config, settings)
    # Configure The Box
    config.vm.box = "laravel/homestead"
    config.vm.hostname = "laravel.dev"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

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

    # Register All Of The Configured Shared Folders
    settings["folders"].each do |folder|
      config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
    end

    #Install AU Locale
    config.vm.provision "shell" do |s|
        s.inline = "bash /vagrant/scripts/locale.sh && bash /vagrant/scripts/wp-cli.sh"
    end

    projects = []
    # Install All The Configured Nginx Sites
    settings["sites"].each do |site|

      projects.push("#{site['name']}.dev")

      args = [site["name"], site["type"]]
      if(site.has_key?("repo"))
        args.push(site["repo"])
      end

      config.vm.provision "shell" do |s|
        #Set up virtual server, database, project, .env file
        s.inline = "bash /vagrant/scripts/serve.sh $1 $2 && bash /vagrant/scripts/create-mysql.sh $1 && bash /vagrant/scripts/git.sh $1 $2 $3 && bash /vagrant/scripts/create-env.sh $1 $2 && bash /vagrant/scripts/composer-update.sh $1"
        s.args = args
      end

      #config.vm.provision "shell" do |s|
        #Run npm install as non sudo user
       # s.inline = "bash /vagrant/scripts/npm-install.sh $1 $2"
       # s.args = [site["name"], site["type"]]
       # s.privileged = false
      #end

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
          s.inline = "service nginx reload && service php5-fpm reload"
      end
    end

    # Update Composer On Every Provision
    #config.vm.provision "shell" do |s|
     # s.inline = "/usr/local/bin/composer self-update"
    #end
  end
end
