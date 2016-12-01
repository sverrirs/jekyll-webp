require 'jekyll/document'

module Jekyll
  module Webp

    #
    # A static file to hold the generated webp image after generation 
    # so that Jekyll will copy it into the site output directory
    class WebpFile < StaticFile
      def write(dest)
        true # Recover from strange exception when starting server without --auto
      end
    end #class WebPImageFile

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

        Jekyll.logger.info "WebP:","Starting"

        # If the site destination directory has not yet been created then create it now. Otherwise, we cannot write our file there.
        Dir::mkdir(site.dest) if !File.directory? site.dest

        # Iterate through every image in each of the image folders and create a webp image
        # if one has not been created already for that image.
        for imgdir in @config['img_dir']
          imgdir_source = File.join(site.source, imgdir)
          Jekyll.logger.info "WebP:","Processing #{imgdir_source}"
          
          # handle only jpg, jpeg, png and gif
          Dir.foreach(imgdir_source) do |imgfile|
          
              # Skip empty stuff
              next if imgfile == '.' or imgfile == '..'
              file_ext = File.extname(imgfile).downcase

              # If the file is not one of the supported formats, exit early
              next if !@config['formats'].include? file_ext

              # TODO: Do an exclude check
              
              # Create the output file path
              file_noext = File.basename(imgfile, file_ext)
              outfile_filename = file_noext+ ".webp"
              outfile_fullpath_webp = File.join(imgdir_source, outfile_filename)

              # Create the full input file name
              infile_fullpath = File.join(imgdir_source, imgfile)
          
              # Check if the file already has a webp alternative?
              # If we're force rebuilding all webp files then ignore the check
              # also check the modified time on the files to ensure that the webp file
              # is newer than the source file, if not then regenerate
              next if !@config['regenerate'] && File.file?(outfile_fullpath_webp) &&
                      File.mtime(outfile_fullpath_webp) > File.mtime(infile_fullpath)      
              
              if( File.file?(outfile_fullpath_webp) && 
                  File.mtime(outfile_fullpath_webp) <= File.mtime(infile_fullpath) )
                Jekyll.logger.info "WebP:", "Change to source image file #{imgfile} detected, regenerating WebP"
                #puts "      WebP: "+File.mtime(outfile_fullpath_webp).strftime('%Y-%m-%d %H:%M:%S')
                #puts "      Source: "+File.mtime(infile_fullpath).strftime('%Y-%m-%d %H:%M:%S')
              end

              # Generate the file
              WebpExec.run(@config['quality'], infile_fullpath, outfile_fullpath_webp)
              
              # Keep the webp file from being cleaned by Jekyll
              site.static_files << WebpFile.new(site, site.dest, imgdir, outfile_filename)
              file_count += 1
              
          end # dir.foreach
        end # img_dir

        Jekyll.logger.info "WebP:","Generator Complete: #{file_count} file(s) generated"

      end #function generate

    end #class WebPGenerator
    
  end #module Webp
end #module Jekyll