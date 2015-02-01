require 'spec_helper'

describe CB::Manage::Contact do
  let(:user) {u = CB::Core::User.new ; u.id = 12; u}
  subject    { CB::Manage::Contact.new(user) }

  before do
  end

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#find_or_create_by_email' do

    it 'finds or create a contact matching the current user and the given email param and return a success splat' do
      CB::Core::Contact.stub(:find_or_create_by)
                       .with(owner_id: user.id, email: 'my@mail.io')
                       .and_return(fake_contact = OpenStruct.new(persisted?: true))

      subject.find_or_create_by_email('my@mail.io').should eq [true, fake_contact]
    end

    it 'returns an error splat if the find_or_create failed, eg. validation failed' do
      CB::Core::Contact.stub(:find_or_create_by)
                       .with(owner_id: user.id, email: 'my@mail.io')
                       .and_return(fake_contact = OpenStruct.new(persisted?: false))
      subject.find_or_create_by_email('my@mail.io').should eq [false, fake_contact]
    end

  end

end