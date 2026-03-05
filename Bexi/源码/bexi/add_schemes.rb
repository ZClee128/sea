require 'xcodeproj'
project_path = 'bexi.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Check if target has Info.plist attributes
if target.build_configurations.first.build_settings['INFOPLIST_KEY_LSApplicationQueriesSchemes']
  puts "Schemes already exist in build settings."
else
  # Add queried schemes
  schemes = "weixin, lark, wxwork, dingtalk"
  
  target.build_configurations.each do |config|
    config.build_settings['INFOPLIST_KEY_LSApplicationQueriesSchemes'] = schemes
  end
  
  project.save
  puts "Added Queried URL Schemes to project configuration."
end
