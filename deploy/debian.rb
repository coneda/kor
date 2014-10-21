#!/usr/bin/env ruby

# Usage:
# deploy/debian.rb

require "erb"

class DebianBuilder

  def initialize(options = {})
    @options = {
      :branch => "master",
      :commit => nil
    }.merge(options)
  end

  attr_reader :options

  def run
    system "rm -rf #{build_dir}"
    system "mkdir -p #{build_dir}"

    treeish = (options[:commit] || options[:branch])
    system "git archive -o #{tarball} #{treeish}"

    system "mkdir -p #{deb_source_dir}/opt/kor/current"
    system "cd #{deb_source_dir}/opt/kor/current ; tar xzf #{tarball}"

    system "mkdir -p #{control_dir}"
    control_files.each do |filename|
      File.open "#{control_dir}/#{filename}", "w" do |f|
        engine = ERB.new(File.read "#{tpl_dir}/#{filename}.erb")
        f.write engine.result(binding)
      end
      system "chmod --reference=#{tpl_dir}/#{filename}.erb #{control_dir}/#{filename}"
    end

    config_files.each do |c|
      dir = File.dirname("#{deb_source_dir}#{c[:path]}")
      system "mkdir -p #{dir}"
      File.open "#{deb_source_dir}#{c[:path]}", "w" do |f|
        engine = ERB.new(File.read "#{tpl_dir}/#{c[:tpl]}.erb")
        f.write engine.result(binding)
      end
    end

    dirs.each do |dir|
      system "mkdir -p #{deb_source_dir}#{dir}"
    end

    system "dpkg-deb -b #{deb_source_dir} #{package_path}"
    system "rm -rf #{deb_source_dir}"
  end

  def config_files
    return [
      {:tpl => "apache", :path => "/etc/apache2/sites-available/kor"},
      {:tpl => "database.yml", :path => "/opt/kor/shared/database.yml"},
      {:tpl => "delayed_job", :path => "/etc/init.d/delayed_job"},
      {:tpl => "gemrc", :path => "/etc/gemrc"},
      {:tpl => "logrotate", :path => "/etc/logrotate.d/kor"},
      {:tpl => "cron", :path => "/etc/cron.d/kor"},
    ]
  end

  def dirs
    ["/opt/kor/shared/log", "/opt/kor/shared/data"]
  end

  def package_path
    "#{build_dir}/coneda-kor.v#{version}.deb"
  end

  def control_files
    ["control", "postinst", "conffiles", "preinst"]
  end

  def control_dir
    "#{deb_source_dir}/DEBIAN"
  end

  def deb_source_dir
    "#{build_dir}/deb_source"
  end

  def version
    File.read('config/version.txt').strip
  end

  def tarball
    "#{build_dir}/coneda-kor.v#{version}.tar.gz"
  end

  def build_dir
    "#{root}/deploy/build"
  end

  def tpl_dir
    "#{root}/deploy/templates"
  end

  def root
    @root ||= File.expand_path(File.dirname(__FILE__) + '/..')
  end

end

branch = `git branch | grep "^\*" | cut -d " " -f 2`.strip
DebianBuilder.new(:branch => branch).run