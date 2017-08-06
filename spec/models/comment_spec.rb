require 'rails_helper'

RSpec.describe Comment, type: :model do
  #pending "add some examples to (or delete) #{__FILE__}"
  
  it {is_expected.to belong_to(:post)}
  it {is_expected.to belong_to(:user)}
  
  it {is_expected.to validate_presence_of(:body)}
end
