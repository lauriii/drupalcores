#!/usr/bin/env ruby

log_args = ARGV[0] || '--since=2011-03-09'
git_command = 'git --git-dir=../drupalcore/.git --work-tree=drupal log 8.2.x ' + log_args + ' -s --format=%s'

Encoding.default_external = Encoding::UTF_8
require 'erb'
require 'yaml'
require 'json'
require_relative 'git-log-parser'

mydir = File.dirname(__FILE__)
name_mappings = YAML::load_file(mydir + '/../config/name_mappings.yml')
targets = YAML::load_file(mydir + '/../config/targets.yml')

p = DrupalCores::GitLogParser.new(['Hi'])

puts p.output.to_json
