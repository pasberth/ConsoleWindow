Gem::Specification.new do |s|
  s.name = "console_window"
  s.version = File.read("VERSION")
  s.authors = ["pasberth"]
  s.description = %{User-friendly Curses Wrapper}
  s.summary = %q{}
  s.email = "pasberth@gmail.com"
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/pasberth/ConsoleWindow"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.add_development_dependency "rspec"
  s.add_development_dependency "term-ansicolor"
  s.add_dependency "give4each"
  s.add_dependency "unicode-display_width"
end
