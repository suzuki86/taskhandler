module TaskHandler
  class Config

    DEFAULT_CONFIG_PATH = "~/.taskhandler/"
    DEFAULT_PROJECT_FILENAME = "projects.yml"
    DEFAULT_CONFIG_FILENAME = "config.yml"

    def load
      config_path = File.expand_path(DEFAULT_CONFIG_PATH + DEFAULT_CONFIG_FILENAME)
      if File.exists?(config_path)
        YAML.load_file config_path
      end
    end
  end
end
