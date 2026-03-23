require 'xcodeproj'

project_path = 'junip.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join('junip', 'Models'), true)
file1 = group.new_reference('CoinManager.swift')
file2 = group.new_reference('StoreManager.swift')
target.add_file_references([file1, file2])

views_group = project.main_group.find_subpath(File.join('junip', 'Views', 'Settings'), true)
file3 = views_group.new_reference('CoinStoreView.swift')
target.add_file_references([file3])

project.save
puts 'Done adding files'
