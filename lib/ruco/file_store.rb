require "digest/md5"
require "fileutils"
require "ruco/core_ext/file"

module Ruco
  class FileStore
    def initialize(folder, options={})
      @folder = File.expand_path(folder)
      @options = options
    end

    def set(key, value)
      FileUtils.mkdir_p @folder unless File.exist? @folder
      File.write(file(key), serialize(value))
      cleanup if @options[:keep]
    end

    def get(key)
      file = file(key)
      deserialize File.binary_read(file) if File.exist?(file)
    end

    def cache(key, &block)
      value = get(key)
      if value.nil?
        value = yield
        set(key, value)
      end
      value
    end

    def delete(key)
      FileUtils.rm(file(key))
    rescue Errno::ENOENT
    end

    def clear
      FileUtils.rm_rf(@folder)
    end

    def file(key)
      "#{@folder}/#{Digest::MD5.hexdigest(key)}.yml"
    end

    private

    def entries
      (Dir.entries(@folder) - ['.','..']).
        map{|entry| File.join(@folder, entry) }.
        sort_by{|file| File.mtime(file) }
    end

    def cleanup
      delete = entries[0...-@options[:keep]] || []
      delete.each{|f| File.delete(f) }
    end

    def serialize(value)
      @options[:string] ? value : Marshal.dump(value)
    end

    def deserialize(value)
      Marshal.load(value)
    end
  end
end
