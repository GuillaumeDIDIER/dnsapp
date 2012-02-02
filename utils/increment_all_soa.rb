#!/usr/bin/ruby

# This script will increment all soa records found on 'dns' and 'reverse_dns' databases. 

print "Incrémentation de tous les serials...\n"

def self.security_level
  :production_confirm
end

require File.expand_path('../init.rb', __FILE__ )

soas = DnsRecord.where( :rtype => 'SOA' ) + ReverseDnsRecord.where( :rtype => 'SOA' )
soas.each do |soa|
  soa.auto_cast
  soa.increment_serial
  print "Hit!\t\033[35m\033[1m#{soa.host}.#{soa.zone} IN SOA "
  print "#{soa.r_primary_ns} #{soa.r_resp_person}"
  print " \033[31m\033[22m#{soa.r_serial}\033[1m\033[35m "
  print "#{soa.r_refresh} #{soa.r_retry} #{soa.r_expire} #{soa.r_minimum}"
  print "\033[22m\033[0m\n"
  soa.save!
end

print "\nTerminé\n"
