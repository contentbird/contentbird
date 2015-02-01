require 'spec_helper'

describe CB::Core::Lead do

subject { CB::Core::Lead.new(email: 'some@email.com') }

  it 'persists and support mass assignment' do
    lead      = CB::Core::Lead.create(email: 'some@email.com')

    lead.persisted?.should be_true
    lead.email.should      eq 'some@email.com'

    lead.update_attributes(token: 'token')
    lead.reload.token.should eq 'token'
  end

  it 'validates the email format' do
    subject.email  = 'some silly string'
    subject.should_not be_valid

    subject.email  = 'some@clever-mail.io'
    subject.should be_valid
  end

  it {should validate_uniqueness_of :email}

  describe '#generate_token!' do
    it 'generates a new token, store it and returns it' do
      SecureRandom.stub(:hex).and_return('first token')
      subject.generate_token!.should eq 'first token'
      subject.reload.token.should    eq 'first token'
    end
    context 'with an existing token' do
      it 'does not generate a new one and returns the one that exists' do
        SecureRandom.should_receive(:hex).never
        subject.token = 'existing token'
        subject.generate_token!.should eq 'existing token'
      end
    end
    context 'given the generated token already exists' do
      it 'generates a new one' do
        CB::Core::Lead.stub(:exists?).with(token: 'first token').and_return true, false
        CB::Core::Lead.stub(:exists?).with(token: 'second token').and_return false

        SecureRandom.stub(:hex).and_return('first token', 'second token')

        subject.generate_token!.should eq 'second token'
      end
    end
  end

  describe 'scopes' do
    it '#to_invite returns leads without tokens' do
      criteria = CB::Core::Lead.to_invite.where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'token'
      criteria.right.should     eq nil
    end
  end

end