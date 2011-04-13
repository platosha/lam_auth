# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lam_auth/version"

Gem::Specification.new do |s|
  s.name        = "lam_auth"
  s.version     = LamAuth::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Max Macovsky", "Anton Platonov"]
  s.email       = ["robotector@gmail.com", "platosha@lookatme.ru"]
  s.homepage    = "http://github.com/macovsky/lam_auth"
  s.summary     = %q{Аутентификация для спецпроектов Lookatme}
  s.description = %q{}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
