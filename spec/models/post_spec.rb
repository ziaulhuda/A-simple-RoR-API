require 'rails_helper'

RSpec.describe Post, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
  #test association
  it {is_expected.to belong_to(:user)}
  it {is_expected.to have_many(:comments).dependent(:destroy)}
  
  it {is_expected.to validate_presence_of(:title)}
  it {is_expected.to validate_presence_of(:body)}
end
