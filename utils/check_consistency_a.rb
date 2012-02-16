#!/usr/bin/ruby

# This script will check consistency for A, CNAME and PTR records.

print "Vérification des enregistrements A, CNAME et PTR...\n"

def self.security_level
  :production_confirm
end

require File.expand_path('../init.rb', __FILE__ )

include ZonesHelper

# Step 1 : unicity
print "1) Unicité des noms...\n"

unicity = {}
non_unique = {}

# Retrieve all records we need
records = DnsRecord.where( :rtype => 'A' ) + DnsRecord.where( :rtype => 'CNAME' )
records = records + ReverseDnsRecord.where( :rtype => 'PTR' )

records.each do |record|
  hostname = "#{record.host}.#{record.zone}"
  if unicity[hostname] == true
    non_unique[hostname] = { :h => record.host, :z => record.zone }
  else
    unicity[hostname] = true
  end
end

# User based correction
print "\033[31m#{non_unique.count} collision(s) trouvée(s)\033[0m\n"
print "Correction :\n" if non_unique.count > 0
non_unique.each do |key, val|
  print "Hostname : \033[31m#{key}\n"
  print "\033[32m0. Ne rien faire\n"

  # Find duplicates
  duplicates = DnsRecord.find( :all, :conditions =>
                 ["host = ? and zone = ? and (rtype = 'A' or rtype = 'CNAME')",
                 val[:h], val[:z]] )
  i = 0
  t = [0]
  duplicates.each do |record|
    i = i + 1
    t.insert( -1, record.rid )
    print "#{i}. IN #{record.rtype} #{record.data}\n"
  end

  keep = nil
  while keep.nil? do
    print "\033[0mQui garder ? > "
    keep = gets
    keep = keep.chomp.to_i
    unless (0..i).include? keep
      keep = nil
    end
  end

  # Remove all other records
  if keep != 0
    duplicates.each do |record|
      if record.rid == t[keep]
        print "=>Garder : #{key} IN #{record.rtype} #{record.data}\n"
      else
        record.destroy
      end
    end
  else
    print "=>Ne rien faire\n"
  end
end


# Step 2 : A <=> PTR consistency check
valid = [] # for step 3
a_with_wrong_ptr = []
print "\n2) Vérification A <=> PTR...\n"
DnsRecord.where( :rtype => 'A' ).each do |record|
  hostname = "#{record.host}.#{record.zone}"
  valid.insert( -1, hostname.downcase )
  hash = reverse_host_and_zone_from_ip record.data
  rhost = hash[:host]
  rzone = hash[:zone]
  ptr1 = ReverseDnsRecord.where( :rtype => 'PTR', :host => rhost, :zone => rzone ).first
  ptr2 = ReverseDnsRecord.where( :rtype => 'PTR', :data => "#{hostname}." ) .first

  if ptr1.nil? && ptr2.nil?
    a_with_wrong_ptr.insert( -1, { :a => record, :action => :new } )
  elsif ptr1.nil?
    a_with_wrong_ptr.insert( -1, { :a => record, :action => :correct, :ptr => ptr2 } )
  elsif ptr2.nil?
    a_with_wrong_ptr.insert( -1, { :a => record, :action => :correct, :ptr => ptr1 } )
  elsif ptr1.rid != ptr2.rid
    a_with_wrong_ptr.insert( -1, { :a => record, :action => :delete,
                                   :ptr1 => ptr1, :ptr2 => ptr2 } )
  end
end

# User based Corection
print "\033[31m#{a_with_wrong_ptr.count} problème(s) trouvé(s)\033[0m\n"
print "Correction :\n" if a_with_wrong_ptr.count > 0
a_with_wrong_ptr.each do |val|
  record = val[:a]
  hostname = "#{record.host}.#{record.zone}"
  print "Hostname : \033[31m#{hostname}\n"

  if val[:action] == :new
    print "\033[33mPas de PTR\n"
  elsif val[:action] == :correct
    print "\033[33mUn PTR incorrect trouvé\n"
  elsif val[:action] == :delete
    print "\033[33mDeux PTR incorrects trouvés\n"
  end

  print "\033[32m0. Ne rien faire\n"
  print "1. Corriger\n"

  keep = nil
  while keep.nil? do
    print "\033[0mQue faire ? > "
    keep = gets
    keep = keep.chomp.to_i
    unless (0..1).include? keep
      keep = nil
    end
  end

  if keep == 0
    print "=>Ne rien faire\n"
  else
    print "=>Corriger\n"
    hash = reverse_host_and_zone_from_ip record.data
    rhost = hash[:host]
    rzone = hash[:zone]

    if val[:action] == :new
      ptr = ReverseDnsRecord.new_ptr
    elsif val[:action] == :correct
      ptr = val[:ptr]
      ptr.auto_cast
    elsif val[:action] == :delete
      ptr = val[:ptr1]
      ptr.auto_cast
      ptr2 = val[:ptr2]
      ptr2.destroy
    end

    ptr.host = rhost
    ptr.zone = rzone
    ptr.data = "#{hostname}."
    ptr.save!
  end
end

# Step 3 : check that CNAME records point to something
graph = {}
cnames = []
print "\n3) Vérification des enregistrments CNAME...\n"
# This will build the reverse graph of CNAMES
DnsRecord.where( :rtype => 'CNAME' ).each do |record|
  hostname = "#{record.host}.#{record.zone}"
  regex = /\A([^.]*\..*)\.\z/i
  match_data = record.data.match regex
  cnames.insert( -1, hostname.downcase )

  if !match_data.nil?
    chostname = match_data[1]
  else
    chostname = "#{record.data}.#{record.zone}"
  end

  chostname = chostname.downcase
  list = (graph[chostname] || []) + [hostname.downcase]
  graph[chostname.downcase] = list
end

# Then we explore the graph starting from A records
while valid.any?
  hostname = valid.pop
  list = (graph[hostname] || [])
  list.each do |cname|
    cnames.delete(cname)
  end
  valid = valid + list
end

# Correction : orphans are suposedly not correct
print "\033[31m#{cnames.count} problème(s) trouvé(s)\033[0m\n"
print "Correction :\n" if cnames.count > 0
DnsRecord.where( :rtype => 'CNAME' ).each do |record|
  hostname = "#{record.host}.#{record.zone}"
  if cnames.include? hostname.downcase
    print "Hostname : \033[31m#{hostname}\n"
    print "\033[33mPointe vers \033[31m'#{record.data}'\033[33m (Destination finale inconnue)\n"

    print "\033[32m0. Ne rien faire\n"
    print "1. Supprimer\n"

    keep = nil
    while keep.nil? do
      print "\033[0mQue faire ? > "
      keep = gets
      keep = keep.chomp.to_i
      unless (0..1).include? keep
        keep = nil
      end
    end

    if keep == 0
      print "=>Ne rien faire\n"
    else
      print "=>Supprimer\n"
      record.destroy
    end
  end
end


print "\nTerminé\n"
