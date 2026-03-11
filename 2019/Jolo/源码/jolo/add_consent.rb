require 'xcodeproj'
project_path = 'jolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('jolo/Controllers', true)

file_path = 'jolo/Controllers/ConsentViewController.swift'
existing = group.files.find { |f| f.path == 'ConsentViewController.swift' }
unless existing
  file_ref = group.new_reference('ConsentViewController.swift')
  target.source_build_phase.add_file_reference(file_ref)
  project.save
  puts "Added ConsentViewController.swift to project"
else
  puts "ConsentViewController.swift already in project"
end
