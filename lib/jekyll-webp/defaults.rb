module Jekyll
  module Webp

    # The default configuration for the Webp generator
    # The values here represent the defaults if nothing is set
    DEFAULT = {
      'enabled'   => false,

      # The flags to pass to the webp binary. For a list of valid parameters check here:
      # https://developers.google.com/speed/webp/docs/cwebp#options
      'flags'     => "-q 75",

      # List of directories containing images to optimize, Nested directories will not be checked
      'img_dir'   => ["/img"],

      # add ".gif" to the format list to generate webp for animated gifs as well
      'formats'   => [".jpeg", ".jpg", ".png", ".tiff"],

      # File extensions for animated gif files 
      'gifs'      => [".gif"],

      # Set to true to always regenerate existing webp files
      'regenerate'=> false,

      # Local path to the WebP utilities to use (relative or absolute)
      # Leave as nil to use the cmd line utilities shipped with the gem, override to use your local install
      'webp_path' => nil,

      # List of files or directories to exclude
      # e.g. custom or hand generated webp conversion files
      'exclude'   => [],

      # List of files or directories to explicitly include 
      # e.g. single files outside of the main image directories
      'include'   => []
    }

  end # module Webp
end # module Jekyll
