require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
	# More info on how to test https://github.com/ryanb/cancan/wiki/Testing-Abilities
  	test "user can only destroy projects which he owns" do
		user = User.create!
		ability = Ability.new(user)
		assert ability.can?(:destroy, Project.new(:user => user))
		assert ability.cannot?(:destroy, Project.new)
	end
end
