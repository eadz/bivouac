require 'fileutils'

helpers do

  def create_site(site)
    cat_key(site)
    init_repo(site)
    add_post_commit(site)
  end

  def init_repo(site)
    FileUtils.mkdir_p File.join(site.directory, 'tmp')
    FileUtils.mkdir_p File.join(site.directory, 'public')
    current_dir = Dir.getwd
    Dir.chdir site.directory
    `git init`
    Dir.chdir current_dir
  end

  def add_post_commit(site)
    post_commit = File.join(site.directory, '.git/hooks/post-receive')
    File.open(post_commit, 'w') do |f|
      f.write <<-HERE
#!/bin/sh
cd #{site.directory};
git reset --hard;
# run initial_deploy_hook here unless /tmp/deployed exists
# initial_deploy should be created in site.directory/deploy-hooks

# config_gem file should be in site.directory/deploy-hooks

# run post_deploy here
# post_deploy_hook should be created in site.directory/deploy

touch #{site.directory}/tmp/restart.txt;
HERE
      f.chmod(0775)
    end
  end

  def cat_key(site)
    File.open("#{ENV['HOME']}/.ssh/authorized_keys", 'a') do |f|
      f << site.ssh_public_key
    end
  end

end
