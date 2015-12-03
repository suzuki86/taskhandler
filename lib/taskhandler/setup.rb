module TaskHandler
  class Setup
    def init
      create_dir
      create_config_file
      create_project_file
    end

    def create_dir
      target = File.expand_path(Config.default_config_path)
      unless File.exists?(target)
        Dir.mkdir File.expand_path(target)
        puts "Directory is created."
      else
        puts "Directory already exists. Skipping to create directory."
      end
    end

    def create_config_file
      target = Config.default_config_file_path
      unless File.exists?(target)
        File.open(File.expand_path(target), "w") do |f|
          config = {"project_file_path" => Config.default_file_path}
          f.write(config.to_yaml)
        end
        puts "config.yml is created."
      else
        puts "config.yml already exists. Skipping to create file."
      end
    end

    def create_project_file
      target = Config.default_file_path
      unless File.exists?(target)
        File.open(File.expand_path(target), "w") do |f|
          f.write("")
        end
        puts "projects.yml is created."
      else
        puts "projects.yml already exists. Skipping to create file."
      end
    end
  end
end
