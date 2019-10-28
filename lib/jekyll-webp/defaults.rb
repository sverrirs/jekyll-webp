module Jekyll
  module Webp

    # The default configuration for the Webp generator
    # The values here represent the defaults if nothing is set
    DEFAULT = {
      'enabled'   => false,

      # The quality of the webp conversion 0 to 100 (where 100 is least lossy)
      'quality'   => 75,

      # Other flags to pass to the webp binary. For a list of valid parameters check here:
      # https://developers.google.com/speed/webp/docs/cwebp#options
      'flags'     => "-m 4 -pass 4 -af",

      # List of directories containing images to optimize, Nested directories only be checked if `nested` is true
      'img_dir'   => ["/img"],

      # Whether to search in nested directories or not
      'nested'   => false,

      # add ".gif" to the format list to generate webp for animated gifs as well
      'formats'   => [".jpeg", ".jpg", ".png", ".tiff"],

      # append .webp to existing extension instead of replacing it
      # (Enables more efficient nginx rules.
      # See http://www.lazutkin.com/blog/2014/02/23/serve-files-with-nginx-conditionally/)
      'append_ext' => false,

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
