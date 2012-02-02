#!/usr/bin/ruby
 
require File.expand_path('../security.rb', __FILE__ )
extend Security

APP_PATH = File.expand_path('../../config/application', __FILE__ )
require File.expand_path('../../config/boot', __FILE__ )
require File.expand_path('../../config/application', __FILE__ )
require File.expand_path('../../record_extensions/ZeModules.rb', __FILE__ )

DnsApp::Application.initialize!

