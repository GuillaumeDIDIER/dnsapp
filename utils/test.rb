#!/usr/bin/ruby

def self.security_level
  :none
end

require File.expand_path('../init.rb', __FILE__ )

print "This is a test script, it should print the first SOA DNS Record found"
soa = DnsRecord.where(:rtype => 'SOA').first
print "\n\n"
print "#{soa.host}.#{soa.zone} IN SOA #{soa.data}"
print "\n"
