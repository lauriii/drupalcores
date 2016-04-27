require 'bundler/setup'

# Add this dir to the load path.
$: << File.dirname(__FILE__)

module DrupalCores
  autoload :GitLogParser, 'drupalcores/git-log-parser'
end
