namespace :db do
  namespace :fixtures do
    desc "Validate Fixtures"
    task :validate => [:environment, :load] do
      name_map = Hash.new { |h,k| h[k] = k }

      Dir.chdir("app/models") do
        map = `grep set_table_name *.rb`.gsub(/[:\'\"]+|set_table_name/, '').split
        Hash[*map].each do |file, name|
          name_map[name] = file.sub(/\.rb$/, '')
        end
      end

      Dir["test/fixtures/*.yml"].each do |fixture|
        fixture = name_map[File.basename(fixture, ".yml")]

        begin
          klass = fixture.classify.constantize
          klass.find(:all).each do |thing|
            unless thing.valid?
              puts "#{fixture}: id ##{thing.id} is invalid:" 
              thing.errors.full_messages.each do |msg|
                puts "   - #{msg}" 
              end
            end
          end
        rescue => e
          puts "#{fixture}: skipping: #{e.message}" 
        end
      end
    end # validate
  end # fixtures
end # db
