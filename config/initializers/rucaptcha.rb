RuCaptcha.configure do
  # Number of chars, default: 4
  self.len = 4
  # Image width, default: 180
  self.width = 80
  # Image height, default: 48
  self.height = 40
  # Cache generated images in file store, this is config files limit, default: 100
  # set 0 to disable file cache.
  self.cache_limit = 100
end