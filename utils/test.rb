#!/usr/bin/ruby
# Execute in 'dns_app' folder, otherwise it won't work.
# Do it like this : "$ ./utils/test.rb" 

APP_PATH = File.expand_path('../../config/application', __FILE__ )
require File.expand_path('../../config/boot', __FILE__ )
require File.expand_path('../../config/application', __FILE__ )
require File.expand_path('../../record_extensions/ZeModules.rb', __FILE__ )

DnsApp::Application.initialize!

print "This is a test script, it should print the first SOA DNS Record found"
soa = DnsRecord.where(:rtype => 'SOA').first
print "\n\n"
print "#{soa.host}.#{soa.zone} IN SOA #{soa.data}"
print "\n"
