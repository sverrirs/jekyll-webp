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
          Jekyll.logger.info "WebP:","Disabled in site.config."
          return
        end

        Jekyll.logger.debug "WebP:","Starting"

        # If the site destination directory has not yet been created then create it now. Otherwise, we cannot write our file there.
        Dir::mkdir(site.dest) if !File.directory? site.dest

        # If nesting is enabled, get all the nested directories too
        if @config['nested']
          newdir = []
          for imgdir in @config['img_dir']
            # Get every directory below (and including) imgdir, recursively
            newdir.concat(Dir.glob(imgdir + "/**/"))
          end
          @config['img_dir'] = newdir
        end

        # Counting the number of files generated
        file_count = 0
        thumb_count = 0

        # Iterate through every image in each of the image folders and create a webp image
        # if one has not been created already for that image.
        for imgdir in @config['img_dir']
          imgdir_source = File.join(site.source, imgdir)
          imgdir_destination = File.join(site.dest, imgdir)
          FileUtils::mkdir_p(imgdir_destination)
          if @config['output_img_sub_dir'] != ""
            FileUtils::mkdir_p(File.join(imgdir_destination, @config['output_img_sub_dir']))
          end
          if @config['thumbs']
            FileUtils::mkdir_p(File.join(imgdir_destination, @config['thumbs_dir']))
          end
          Jekyll.logger.info "WebP:","Processing #{imgdir_source}"

          # handle only jpg, jpeg, png and gif
          for imgfile in Dir[imgdir_source + "**/*.*"]
              imgfile_relative_path = File.dirname(imgfile.sub(imgdir_source, ""))

              # Skip empty stuff
              file_ext = File.extname(imgfile).downcase

              # If the file is not one of the supported formats, exit early
              next if !@config['formats'].include? file_ext

              # TODO: Do an exclude check

              # Create the output file path
              outfile_filename = if @config['append_ext']
                File.basename(imgfile) + '.webp'
              else
                file_noext = File.basename(imgfile, file_ext)
                file_noext + ".webp"
              end

              small_outfile_filename = File.basename(imgfile, file_ext) + "-small" + ".webp"
              
              FileUtils::mkdir_p(imgdir_destination + imgfile_relative_path)
              outfile_fullpath_webp = File.join(imgdir_destination + imgfile_relative_path, @config['output_img_sub_dir'], outfile_filename)
              small_outfile_fullpath_webp = File.join(imgdir_destination + imgfile_relative_path, @config['output_img_sub_dir'], small_outfile_filename)
              thumb_outfile_fullpath_webp = File.join(imgdir_destination + imgfile_relative_path, @config['thumbs_dir'], outfile_filename)

              # Check if the file already has a webp alternative?
              # If we're force rebuilding all webp files then ignore the check
              # also check the modified time on the files to ensure that the webp file
              # is newer than the source file, if not then regenerate
              if @config['regenerate'] || !File.file?(outfile_fullpath_webp) ||
                 File.mtime(outfile_fullpath_webp) <= File.mtime(imgfile)
                Jekyll.logger.info "WebP:", "Change to source image file #{imgfile} detected, regenerating WebP"

                # Generate the file
                WebpExec.run(@config['quality'], @config['flags'], imgfile, outfile_fullpath_webp, @config['webp_path'])
                file_count += 1

                if @config['generate_50p']
                  # Get the image size
                  Jekyll.logger.info "WebP:", "Generating small image file #{outfile_filename}"
                  image_size = FastImage.size(imgfile, :raise_on_failure=>true, :timeout=>2.0)
                  h_width = image_size[0] / 2
                  size_flags = "-resize #{h_width} 0" + " " + @config['flags']
                  WebpExec.run(@config['quality'], size_flags, imgfile, small_outfile_fullpath_webp, @config['webp_path'])
                end
                
                # Generate the thumbnails
                if @config['thumbs']
                  Jekyll.logger.info "WebP:", "Generating thumbnail for #{outfile_filename} in #{@config['thumbs_dir']}"
                  thumb_flags = "-resize 400 0" + " " + @config['flags']
                  WebpExec.run(@config['quality'], thumb_flags, imgfile, thumb_outfile_fullpath_webp, @config['webp_path'])
                  thumb_count += 1
                end
              end

              if File.file?(outfile_fullpath_webp)
                # Keep the webp file from being cleaned by Jekyll
                site.static_files << WebpFile.new(site,
                                                  site.dest,
                                                  File.join(imgdir, imgfile_relative_path, @config['output_img_sub_dir']),
                                                  outfile_filename)
                if @config['thumbs']
                  site.static_files << WebpFile.new(site,
                                                  site.dest,
                                                  File.join(imgdir, imgfile_relative_path, @config['thumbs_dir']),
                                                  outfile_filename)
                end
                if @config['generate_50p']
                  site.static_files << WebpFile.new(site,
                                                  site.dest,
                                                  File.join(imgdir, imgfile_relative_path, @config['output_img_sub_dir']),
                                                  small_outfile_filename)
                end
              end
          end # dir.foreach
        end # img_dir

        Jekyll.logger.info "WebP:","Generator Complete: #{file_count} file(s) generated #{thumb_count} thumbnail(s) generated"

      end #function generate

    end #class WebPGenerator

  end #module Webp
end #module Jekyll
