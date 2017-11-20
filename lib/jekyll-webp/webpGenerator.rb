require 'jekyll/document'
require 'fileutils'

module Jekyll
  module Webp

    #
    # A static file to hold the generated webp image after generation
    # so that Jekyll will copy it into the site output directory
    class WebpFile < StaticFile
      def write(dest)
        true # Recover from strange exception when starting server without --auto
      end
    end #class WebpFile

    class WebpGenerator < Generator
      # This generator is safe from arbitrary code execution.
      safe true

      # This generator should be passive with regard to its execution
      priority :lowest

      # Generate paginated pages if necessary (Default entry point)
      # site - The Site.
      #
      # Returns nothing.
      def generate(site)

        # Retrieve and merge the configuration from the site yml file
        @config = DEFAULT.merge(site.config['webp'] || {})

        # If disabled then simply quit
        if !@config['enabled']
          Jekyll.logger.info "WebP:", "Disabled in site.config."
          return
        end

        Jekyll.logger.debug "WebP:", "Starting"

        # If the site destination directory has not yet been created then create it now. Otherwise, we cannot write our file there.
        Dir::mkdir(site.dest) if !File.directory? site.dest

        # Counting the number of files generated
        file_count = 0

        # Iterate through every image in each of the image folders and create a webp image
        # if one has not been created already for that image.
        for source in @config['img_dir']
          source_full_path = File.join(site.source, source)
          destination_full_path = File.join(site.dest, source)
          FileUtils::mkdir_p destination_full_path
          Jekyll.logger.info "WebP:", "Processing #{source_full_path}"

          for file_full_path in Dir[source_full_path + "/**/*.*"]
            file_relative_path = file_full_path.sub(source_full_path, "")

            file_extension = File.extname(file_full_path).downcase

            # If the file is not one of the supported formats, exit early
            next if !@config['formats'].include? file_extension

            # TODO: Do an exclude check

            # Create the output file path
            file_no_extension = File.basename(file_full_path, file_extension)
            relative_path = File.dirname(file_relative_path)
            FileUtils::mkdir_p(destination_full_path + relative_path)
            outfile_fullpath_webp = File.join(destination_full_path + relative_path, file_no_extension + ".webp")

            # Check if the file already has a webp alternative?
            # If we're force rebuilding all webp files then ignore the check
            # also check the modified time on the files to ensure that the webp file
            # is newer than the source file, if not then regenerate
            next if !@config['regenerate'] && File.file?(outfile_fullpath_webp) &&
                    File.mtime(outfile_fullpath_webp) > File.mtime(source_full_path)

            if( File.file?(outfile_fullpath_webp) &&
                File.mtime(outfile_fullpath_webp) <= File.mtime(source_full_path) )
              Jekyll.logger.info "WebP:", "Change to source image file #{file} detected, regenerating WebP"
            end

            Jekyll.logger.info "WebP:", "Generating #{outfile_fullpath_webp}"
            # Generate the file
            WebpExec.run(@config['quality'], file_full_path, outfile_fullpath_webp)

            # Keep the webp file from being cleaned by Jekyll
            site.static_files << WebpFile.new(site, site.dest, source, outfile_fullpath_webp)
            file_count += 1
          end # file_full_path
        end # img_dir

        Jekyll.logger.info "WebP:", "Generator Complete: #{file_count} file(s) generated"

      end #function generate

    end #class WebPGenerator

  end #module Webp
end #module Jekyll
