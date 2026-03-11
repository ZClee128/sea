require 'xcodeproj'

project_path = 'tego.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

def add_files_to_group(project, target, group_name, path)
  # Ensure the subpath exists in the project
  group = project.main_group.find_subpath(File.join('tego', group_name), true)
  # Set path relative to the group
  group.set_source_tree('<group>')
  group.set_path(group_name)
  
  puts "Checking #{path}"
  Dir.glob(File.join(path, '*.swift')).each do |file|
    basename = File.basename(file)
    puts "Adding #{basename}"
    # check if reference already exists
    existing = group.files.find { |f| f.path == basename }
    unless existing
        file_ref = group.new_reference(basename)
        target.add_file_references([file_ref])
    end
  end
end

add_files_to_group(project, target, 'Views', 'tego/Views')
add_files_to_group(project, target, 'Models', 'tego/Models')
add_files_to_group(project, target, 'ViewModels', 'tego/ViewModels')

project.save
puts "Saved project"
