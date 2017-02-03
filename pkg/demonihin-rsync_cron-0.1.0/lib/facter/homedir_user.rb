#Creates facts with users properties if possible.
#output format - hash of user => homedir_path
passwd_entries = `getent passwd`.split(/\r?\n/)
homedir_hash = {}
passwd_entries.each{|user|
  props = user.split(/:/)
  #print "homedir_path_#{props[0]}=#{props[5]}\n"
  homedir_hash[props[0]] = props[5]
}

#print homedir_hash
Facter.add('home_dirs') do
  setcode do
    homedir_hash
  end
end
