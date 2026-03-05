require 'xcodeproj'

project_path = '/Users/lizhicong/Desktop/sea/Bexi/源码/bexi/bexi.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath(File.join('bexi'), true)
file_path = '/Users/lizhicong/Desktop/sea/Bexi/源码/bexi/bexi/ReviewerNoteView.swift'

file_ref = group.new_reference(file_path)
target.add_file_references([file_ref])
project.save

puts "Added ReviewerNoteView.swift to Xcode project."
