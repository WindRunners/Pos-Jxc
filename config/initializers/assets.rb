require  'find'
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(rediscss/sessionindex.css registjs/jquery-1.10.2.min.js registjs/jquery.form.js rediscss/regismail.css rediscss/regissh.css rediscss/regisindex.css rediscss/registx.css ace/ace-extra.js ace/html5shiv.js ace/respond.js ace/ace-part2.css ace/ace-ie.css ace/bootstrap.min.css ace/jquery.js ace/bootbox.js angular.min.js)

#需要整合的样式扩展名
NEED_TO_COMPILE_EXT = %w(.scss .css .coffee .js)

# # puts Dir::open("app/assets/javascripts")["*.js"] # 匹配 "foo.c"、 "foo.rb" 等等
# puts Dir::open("#{Dir::pwd}/app/assets/javascripts"){|dir|
#    puts dir
# } # 匹配 "foo.c"、 "foo.rb" 等等

#js文件
Find.find("#{Dir::pwd}/app/assets/javascripts") do |filename|
  ext = File.extname(filename)
  if File.file?(filename) && NEED_TO_COMPILE_EXT.include?(ext)
    Rails.application.config.assets.precompile << "#{File.basename(filename,'.*')}.js"
  end
  # puts "文件名:#{File.basename(filename)} , 扩展名:#{File.extname(filename)} " if File.file?(filename)
end

#js文件
Find.find("#{Dir::pwd}/app/assets/stylesheets") do |filename|
  ext = File.extname(filename)
  if File.file?(filename) && NEED_TO_COMPILE_EXT.include?(ext)
    Rails.application.config.assets.precompile << "#{File.basename(filename,'.*')}.css"
  end
  # puts "文件名:#{File.basename(filename)} , 扩展名:#{File.extname(filename)} " if File.file?(filename)
end
