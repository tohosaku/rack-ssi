# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/ssi/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tohosaku"]
  gem.email         = ["ny@cosmichorror.org"]
  gem.description   = %q{rack-ssi is a middleware to realize the function of SSI on the rack. (Currently only supports include) }
  gem.summary       = %q{rack-ssi is a middleware to realize the function of SSI on the rack. (Currently only supports include) }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-ssi"
  gem.require_paths = ["lib"]
  gem.version       = Rack::SSI::VERSION
end
