require 'os'

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

        full_path = File.join(bin_path, exe_name)

        # Construct the full program call
        cmd = "\"#{full_path}\" -quiet -mt -q #{quality.to_s} \"#{input_file}\" -o \"#{output_file}\""

        puts "Command: "+cmd
        
        # Execute the command
        retValue = %x[ #{cmd} ]

        # Return any captured return value
        return retValue 
      end #function run

      #
      # Returns the correct executable name depending on the OS platform and OS architecture
      #
      def self.exe_name
        if OS.mac?
          return "osx-cwebp"
        elsif OS.windows?
          if OS.32bit?
            return "win-x86-cwebp.exe"
          else
            return "win-x64-cwebp.exe"
          end
        elsif OS.unix? || OS.linux?
          if OS.32bit?
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

    def OS.32bit?
      return 1.size != 8
    end

    def OS.64bit?
      return 1.size == 8
    end
  end #module OS
end #module Jekyll