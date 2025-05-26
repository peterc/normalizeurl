require_relative "lib/normalizeurl2025/version"

Gem::Specification.new do |spec|
  spec.name = "normalizeurl2025"
  spec.version = Normalizeurl2025::VERSION
  spec.authors = ["Peter Cooper"]
  spec.email = ["git@peterc.org"]

  spec.summary = "A Ruby library for normalizing URLs"
  spec.description = "Normalizes URLs by removing tracking parameters, session IDs, and other extraneous elements whilst preserving important parameters"
  spec.homepage = "https://github.com/peterc/normalizeurl2025"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/peterc/normalizeurl2025"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
