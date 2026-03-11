require 'xcodeproj'
project_path = 'jolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first # jolo
group = project.main_group.find_subpath('jolo', true)

# check if it already exists
existing = group.files.find { |f| f.path == 'video.mp4' }
unless existing
  file_ref = group.new_reference('video.mp4')
  target.resources_build_phase.add_file_reference(file_ref)
  project.save
  puts "Added video.mp4 to project"
else
  puts "video.mp4 already in project"
end
