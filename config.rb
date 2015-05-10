###
# Blog settings
###

# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  blog.year_link = "{year}.html"
  blog.month_link = "{year}/{month}.html"
  blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

activate :syntax, :line_numbers => true
set :markdown_engine, :redcarpet
set :markdown,
  :fenced_code_blocks => true,
  :smartypants => true,
  :footnotes => true
page "/feed.xml", layout: false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
# Configuration variables specific to each project
#------------------------------------------------------------------------
AWS_BUCKET                      = [ENV]['AWS_BUCKET']

# Variables: Sent in on CLI by rake task via ENV
#------------------------------------------------------------------------
AWS_ACCESS_KEY                  = ENV['AWS_ACCESS_KEY']
AWS_SECRET                      = ENV['AWS_SECRET']
AWS_CLOUDFRONT_DISTRIBUTION_ID  = ENV['AWS_CLOUDFRONT_DISTRIBUTION_ID']

# https://github.com/fredjean/middleman-s3_sync
activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = AWS_BUCKET # The name of the S3 bucket you are targeting. This is globally unique.
  s3_sync.aws_access_key_id          = AWS_ACCESS_KEY
  s3_sync.aws_secret_access_key      = AWS_SECRET
  s3_sync.delete                     = false # We delete stray files by default.
  s3_sync.acl                        = 'public-read'
  s3_sync.region                     = 'us-west-2'
end

# https://github.com/andrusha/middleman-cloudfront
activate :cloudfront do |cf|
  cf.access_key_id                    = AWS_ACCESS_KEY
  cf.secret_access_key                = AWS_SECRET
  cf.distribution_id                  = AWS_CLOUDFRONT_DISTRIBUTION_ID
  # cf.filter = /\.html$/i
end
