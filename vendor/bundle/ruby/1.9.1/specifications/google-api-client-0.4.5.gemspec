# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{google-api-client}
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Bob Aman}]
  s.date = %q{2012-07-31}
  s.description = %q{The Google API Ruby Client makes it trivial to discover and access supported
APIs.
}
  s.email = %q{bobaman@google.com}
  s.executables = [%q{google-api}]
  s.extra_rdoc_files = [%q{README.md}]
  s.files = [%q{bin/google-api}, %q{README.md}]
  s.homepage = %q{http://code.google.com/p/google-api-ruby-client/}
  s.rdoc_options = [%q{--main}, %q{README.md}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Package Summary}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<signet>, [">= 0.4.1"])
      s.add_runtime_dependency(%q<addressable>, [">= 2.3.2"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.1.0"])
      s.add_runtime_dependency(%q<autoparse>, [">= 0.3.2"])
      s.add_runtime_dependency(%q<faraday>, ["~> 0.8.1"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<extlib>, [">= 0.9.15"])
      s.add_runtime_dependency(%q<launchy>, [">= 2.1.1"])
      s.add_development_dependency(%q<rake>, [">= 0.9.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
    else
      s.add_dependency(%q<signet>, [">= 0.4.1"])
      s.add_dependency(%q<addressable>, [">= 2.3.2"])
      s.add_dependency(%q<uuidtools>, [">= 2.1.0"])
      s.add_dependency(%q<autoparse>, [">= 0.3.2"])
      s.add_dependency(%q<faraday>, ["~> 0.8.1"])
      s.add_dependency(%q<multi_json>, [">= 1.0.0"])
      s.add_dependency(%q<extlib>, [">= 0.9.15"])
      s.add_dependency(%q<launchy>, [">= 2.1.1"])
      s.add_dependency(%q<rake>, [">= 0.9.0"])
      s.add_dependency(%q<rspec>, [">= 2.11.0"])
    end
  else
    s.add_dependency(%q<signet>, [">= 0.4.1"])
    s.add_dependency(%q<addressable>, [">= 2.3.2"])
    s.add_dependency(%q<uuidtools>, [">= 2.1.0"])
    s.add_dependency(%q<autoparse>, [">= 0.3.2"])
    s.add_dependency(%q<faraday>, ["~> 0.8.1"])
    s.add_dependency(%q<multi_json>, [">= 1.0.0"])
    s.add_dependency(%q<extlib>, [">= 0.9.15"])
    s.add_dependency(%q<launchy>, [">= 2.1.1"])
    s.add_dependency(%q<rake>, [">= 0.9.0"])
    s.add_dependency(%q<rspec>, [">= 2.11.0"])
  end
end
