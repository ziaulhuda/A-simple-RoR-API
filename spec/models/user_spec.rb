require 'rails_helper'

RSpec.describe User, type: :model do
 # pending "add some examples to (or delete) #{__FILE__}"
 it {is_expected.to have_many(:posts).dependent(:destroy)}
 it {is_expected.to have_many(:comments).dependent(:destroy)}
 
 it {is_expected.to validate_presence_of(:name)}
 it {is_expected.to validate_presence_of(:email)}
 it {is_expected.to validate_presence_of(:password)}
 it {is_expected.to validate_uniqueness_of(:email)}
 it {is_expected.to validate_uniqueness_of(:auth_token)}
 
end
