namespace :sword do
  namespace :ci do
    desc "Set up test config files"
    task :config_files do # rubocop:disable Rails/RakeEnvironment
      # yml templates
      Dir.glob(File.join(Rails.root, "config/templates/*.template.yml")).each do |template_yml_path|
        target_yml_path = File.join(Rails.root, 'config', File.basename(template_yml_path).sub(".template.yml", ".yml"))
        if File.exist?(target_yml_path)
          puts Rainbow("File already exists (skipping): #{target_yml_path}").blue.bright + "\n"
          next
        end
        target_yml = YAML.load_file(template_yml_path)
        File.open(target_yml_path, 'w') {|f| f.write target_yml.to_yaml }
        puts Rainbow("Created file at: #{target_yml_path}").green
      end
      Dir.glob(File.join(Rails.root, "config/templates/*.template.yml.erb")).each do |template_yml_path|
        target_yml_path = File.join(Rails.root, 'config', File.basename(template_yml_path).sub(".template.yml.erb", ".yml"))
        if File.exist?(target_yml_path)
          puts Rainbow("File already exists (skipping): #{target_yml_path}").blue.bright + "\n"
          next
        end
        target_yml = YAML.load(ERB.new(File.read(template_yml_path)).result(binding))
        File.open(target_yml_path, 'w') {|f| f.write target_yml.to_yaml }
        puts Rainbow("Created file at: #{target_yml_path}").green
      end
    end
  end
end