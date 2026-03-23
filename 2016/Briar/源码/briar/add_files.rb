require 'xcodeproj'
project_path = '/Users/lizhicong/Desktop/sea/2016/Briar/源码/briar/briar.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Helper to find or create group
def ensure_group(parent, name)
  group = parent.children.find { |c| c.display_name == name || c.path == name }
  unless group
    group = parent.new_group(name, name)
  end
  group
end

main_group = project.main_group.children.find { |c| c.display_name == 'briar' || c.path == 'briar' }

# Add Agreement.txt
unless main_group.children.find { |c| c.path == 'Agreement.txt' }
  agreement_ref = main_group.new_reference('Agreement.txt')
  target.add_resources([agreement_ref])
end

# Ensure Models group in Xcode
models_group = ensure_group(main_group, 'Models')
unless models_group.children.find { |c| c.path == 'Product.swift' }
  product_ref = models_group.new_reference('Product.swift')
  target.source_build_phase.add_file_reference(product_ref, true)
end

# Ensure Views group in Xcode
views_group = ensure_group(main_group, 'Views')
views_files = %w[RootView.swift AgreementView.swift HomeView.swift ProductDetailView.swift VideoPlayerView.swift SettingsView.swift FavoritesView.swift MainTabView.swift]

views_files.each do |file|
  unless views_group.children.find { |c| c.path == file }
    ref = views_group.new_reference(file)
    target.source_build_phase.add_file_reference(ref, true)
  end
end

project.save
puts "Successfully added files to Xcode project."
