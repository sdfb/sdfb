seed_file = Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb")
load(seed_file) if File.exist?(seed_file)
