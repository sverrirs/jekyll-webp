require 'open3'

module Jekyll
  module Webp

    class WebpExec

      #
      # Runs the WebP executable for the given input parameters
      # the function detects the OS platform and architecture automatically
      #
      def self.run(quality, input_file, output_file)

        # What is the path to the execs inside the gem? perhaps just bin/?
        bin_path = "bin/"

        # What is the OS and architecture specific executable name?
        exe_name = WebpExec.exe_name

        # We need to locate the Gems bin path as we're currently running inside the
        # jekyll site working directory
        # http://stackoverflow.com/a/10083594/779521
        gem_spec = Gem::Specification.find_by_name("jekyll-webp")
        gem_root = gem_spec.gem_dir

        # Construct the full path to the executable
        full_path = File.join(gem_root, bin_path, exe_name)

        # Construct the full program call
        cmd = "\"#{full_path}\" -quiet -mt -m 6 -pass 10 -q #{quality.to_s} \"#{input_file}\" -o \"#{output_file}\""

        # Execute the command
        stdin, stdout, stderr = Open3.popen3(cmd)

        # Return any captured return value
        return [stdin, stdout, stderr]
      end #function run

      #
      # Returns the correct executable name depending on the OS platform and OS architecture
      #
      def self.exe_name
        if OS.mac?
          return "osx-cwebp"
        elsif OS.windows?
          if OS.x32?
            return "win-x86-cwebp.exe"
          else
            return "win-x64-cwebp.exe"
          end
        elsif OS.unix? || OS.linux?
          if OS.x32?
            return "linux-x86-cwebp"
          else
            return "linux-x64-cwebp"
          end
        else
          raise ArgumentError.new("OS platform could not be identified (gem can only be run on linux,osx or windows)")
        end
      end #function exe_name

    end #class WebpExec

  end #module Webp

  module OS
    def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def OS.unix?
      !OS.windows?
    end

    def OS.linux?
      OS.unix? and not OS.mac?
    end

    def OS.x32?
      return 1.size != 8
    end

    def OS.x64?
      return 1.size == 8
    end
  end #module OS
end #module Jekyll
