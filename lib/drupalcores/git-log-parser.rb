#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8

module DrupalCores
  class GitLogParser
  
    attr_reader :contributors, :commits, :reverts
  
    # Create a new instance
    #
    # @param [Array] lines
    # @param [Hash] name_mappings
    def initialize(lines, name_mappings = {})
      @lines = lines
      @name_mappings = name_mappings
      @contributors = {}
      @commits = []
      @reverts = []
      @issue_regexp = /#[0-9]+/
      @reverts_regexp = /^Revert \"(?<credits>.+#[0-9]+.* by [^:]+:).*/
      @reverts_regexp_loose = /^Revert .*(?<issue>#[0-9]+).*/
    end
  
    def parse_lines
      @lines.each do |c|
        if m = c.match(@reverts_regexp)
          reverts << m[:credits]
        elsif m = c.match(@reverts_regexp_loose)
          reverts << m[:issue]
        else
          commits << c
        end
      end
    end
  
    def remove_reverts
       @commits.each_with_index do |c, i|
         if r = @reverts.index{ |item| c.index(item) == 0 }
          @commits.delete_at(i)
          @reverts.delete_at(r)
        end
      end
  
      @commits.to_enum.with_index.reverse_each do |c, i|
        if r = reverts.index{ |item| item[@issue_regexp] == c[@issue_regexp] }
          @commits.delete_at(i)
          @reverts.delete_at(r)
        end
      end
    end
  
    def find_contributors
      contributors = Hash.new(0)
      @commits.each do |c|
        c.gsub(/\-/, '_').scan(/\s(?:by\s?)([[:word:]\s,.|]+):/i).each do |people|
          people[0].split(/(?:,|\||\band\b|\bet al(?:.)?)/).each do |p|
            name = p.strip.downcase
            contributors[@name_mappings[name] || name] += 1 unless p.nil?
          end
        end
      end
  
      @contributors = Hash[contributors.sort_by {|k, v| v }.reverse]
    end
  
    def output
      parse_lines
      remove_reverts
      find_contributors
      {
        :date => Time.new,
        :count => @contributors.length,
        :graph => {
          :one => @contributors.select {|k,v| v < 2}.length,
          :twoTen => @contributors.select {|k,v| (v > 1 && v < 11) }.length,
          :TenOver => @contributors.select {|k,v| v > 10}.length
        },
        :contributors => @contributors
      }
    end
  
  end
end
