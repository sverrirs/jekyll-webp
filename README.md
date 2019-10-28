[![Gem Version](https://img.shields.io/gem/v/jekyll-webp.svg)](https://rubygems.org/gems/jekyll-webp)
[![Gem](https://img.shields.io/gem/dt/jekyll-webp.svg)](https://rubygems.org/gems/jekyll-webp)
[![Join the chat at https://gitter.im/jekyll-webp/Lobby](https://badges.gitter.im/jekyll-webp/Lobby.svg)](https://gitter.im/jekyll-webp/Lobby)
[![Dependency Status](https://gemnasium.com/badges/github.com/sverrirs/jekyll-webp.svg)](https://gemnasium.com/github.com/sverrirs/jekyll-webp)
[![Code Climate](https://codeclimate.com/github/sverrirs/jekyll-webp/badges/gpa.svg)](https://codeclimate.com/github/sverrirs/jekyll-webp)
[![security](https://hakiri.io/github/sverrirs/jekyll-webp/master.svg)](https://hakiri.io/github/sverrirs/jekyll-webp/master)

# WebP Generator for Jekyll
WebP Image Generator for Jekyll Sites can automatically generate WebP images for all images on your static site and serve them when possible. View on [rubygems.org](https://rubygems.org/gems/jekyll-webp).

> Read more about this tool on my blog at <a href="https://blog.sverrirs.com/2016/06/webp-generator-for-jekyll-sites.html" target="_blank">blog.sverrirs.com</a>

## Installation

```
gem install jekyll-webp
```

The release includes all necessary files to run, including the WebP redistributable executable files.

> Currently the release includes the v0.6.1 version of the WebP utilities for Windows, Linux and Mac OS X 10.9 (Mountain Lion). Other versions and releases can be downloaded directly from <a href="https://developers.google.com/speed/webp/docs/precompiled" target="_blank">the Google page</a>.

Add the gem to your `Gemfile` and to Jekyll's `_config.yml` then run `jekyll serve` again and you should see the generator run during site generation.

## Configuration
The plugin can be configured in the site's `_config.yml` file by including the `webp` configuration element

``` yml
############################################################
# Site configuration for the WebP Generator Plugin
# The values here represent the defaults if nothing is set
webp:
  enabled: true
  
  # The quality of the webp conversion 0 to 100 (where 100 is least lossy)
  quality: 75

  # List of directories containing images to optimize, nested directories will only be checked if `nested` is true
  # By default the generator will search for a folder called `/img` under the site root and process all jpg, png and tiff image files found there.
  img_dir: ["/img"]

  # Whether to search in nested directories or not
  nested: false

  # add ".gif" to the format list to generate webp for animated gifs as well
  formats: [".jpeg", ".jpg", ".png", ".tiff"]

  # File extensions for animated gif files 
  gifs: [".gif"]

  # Set to true to always regenerate existing webp files
  regenerate: false

  # Local path to the WebP utilities to use (relative or absolute)
  # Omit or leave as nil to use the utilities shipped with the gem, override only to use your local install
  webp_path: nil

  # List of files or directories to exclude
  # e.g. custom or hand generated webp conversion files
  exclude: []

  # append '.webp' to filename after original extension rather than replacing it.
  # Default transforms `image.png` to `image.webp`, while changing to true transforms `image.png` to `image.png.webp`
  append_ext: false
############################################################
```

## Simplest use: HTML
In case you don't have control over your webserver then using the `<picture>` element and specifying all image formats available is the best option. This way the browser will decide which format to use based on its own capabilities. 

``` html
<picture>
  <source srcset="/path/to/image.webp" type="image/webp">
  <img src="/path/to/image.jpg" alt="">
</picture>
```

## Advanced use: Webserver Configuration
If you can, then configuring your webserver to serve your new _.webp_ files to clients that support the format is probably the least problematic approach. This way you don't need to make any changes to your HTML files as your webserver will automatically serve WebP images when the client supports them. 

Below is an example for a .htaccess configuration section in an Apache web-server. It will redirect users to webp images whenever possible.

```
####################
# Attempt to redirect images to WebP if one exists 
# and the client supports the file format
####################
# check if browser accepts webp
RewriteCond %{HTTP_ACCEPT} image/webp 

# check if file is jpg or png
RewriteCond %{REQUEST_FILENAME} (.*)\.(jpe?g|png)$

# check if corresponding webp file exists image.png -> image.webp
RewriteCond %1\.webp -f

# serve up webp instead
RewriteRule (.+)\.(jpe?g|png)$ $1.webp [T=image/webp,E=accept:1]

AddType image/webp .webp
```

> Depending on other configurations in your `.htaccess` file you might have to update your `ExpiresByType`, `ExpiresDefault` and `Header set Cache-Control` directives to include the webp format as well.

