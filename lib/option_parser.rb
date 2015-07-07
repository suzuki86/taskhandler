require 'optparse'

module TaskHandler
  class OptionParser < ::OptionParser
    def self.parse_options(argv)
      # Parse options
      options = {}
      opt = OptionParser.new
      opt.on('-t [TASKNAME]') do |v|
        options[:taskname] = v
      end
      opt.on('-d') do |v|
        options[:duedate] = v
      end
      opt.on('-p [PROJECT]') do |v|
        options[:project] = v
      end
      opt.on('-s [SORTBY]') do |v|
        options[:sortby] = v
      end
      opt.on('-f [FILE_PATH]') do |v|
        options[:file_path] = v
      end
      opt.on('-a') do |v|
        options[:display_all] = v
      end
      opt.parse!(argv)
      options
    end
  end
end
