require_relative 'lib/rentdynamics/version'

Gem::Specification.new do |spec|
  spec.name          = "rentdynamics"
  spec.version       = RentDynamics::VERSION
  spec.authors       = ["Levicus"]
  spec.email         = ["levi@rentdynamics.com"]

  spec.summary       = "Used to interact with the rentdynamics api"
  spec.description   = "Used to interact with the rentdynamics api"
  spec.homepage      = "https://www.rentdynamics.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RentDynamics/rentdynamics-rb"
  spec.metadata["changelog_uri"] = "https://github.com/RentDynamics/rentdynamics-rb/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.2"
end
