module Ruco
  class FileStore
    def initialize(folder, options)
      @folder = folder
      @options = options
    end

    def set(key, value)
      `mkdir -p #{@folder}` unless File.exist? @folder
      File.write(file(key), serialize(value))
      cleanup
    end

    def get(key)
      file = file(key)
      deserialize File.read(file) if File.exist?(file)
    end

    private

    def cleanup
      delete = `ls -t #{@folder}`.split("\n")[@options[:keep]..-1] || []
      delete.each{|f| File.delete("#{@folder}/#{f}") }
    end

    def file(key)
      "#{@folder}/#{key.hash}.yml"
    end

    def serialize(value)
      Marshal.dump(value)
    end

    def deserialize(value)
      Marshal.load(value)
    end
  end
end