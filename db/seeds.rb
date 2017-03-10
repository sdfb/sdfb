required_user_atts = {
  password: '22scaddoo',
  password_confirmation: '22scaddoo',
  first_name: 'Franny',
  last_name: 'Baker',
  user_type: 'Standard',
  is_active: true
}
User.where(email: 'sdfbadmin@example.com', username: 'sdfbadmin').first_or_create!(required_user_atts)
User.where(email: 'odnbadmin@example.com', username: 'odnbadmin').first_or_create!(required_user_atts)
required_user_atts.merge!({user_type: 'Curator'})
User.where(email: 'curator@example.com', username: 'curator').first_or_create!(required_user_atts)
required_user_atts.merge!({user_type: 'Admin'})
User.where(email: 'administrator@example.com', username: 'administrator').first_or_create!(required_user_atts)

seed_file = Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb")

load(seed_file) if File.exist?(seed_file)
