describe CB::Subscribe::Lead do

  let(:lead) {l = CB::Core::Lead.new(email: 'lead@email.com');l.id=13;l}
  subject { CB::Subscribe::Lead.new }

  describe '#create' do
    it 'creates a lead Object and returns it with success true' do
      CB::Core::Lead.should_receive(:create).with(email: 'some@email.com').and_return(new_lead = double('lead', persisted?: true))
      subject.create('some@email.com').should eq [true, new_lead]
    end
    it 'creates a lead Object and returns it with success false if creation failed' do
      CB::Core::Lead.should_receive(:create).with(email: 'some@email.com').and_return(new_lead = double('lead', persisted?: false))
      subject.create('some@email.com').should eq [false, new_lead]
    end
  end

  describe '#invite' do
    it 'generates a token on the given lead an sends an invitation email' do
      lead.stub(:generate_token!).and_return('invitation_token')
      JobRunner.should_receive(:run).with(SendEmail, 'invite_lead', 'CB::Core::Lead', 13)
      subject.invite(lead)
    end
  end

  describe '#find' do
    it 'returns the lead with the given token or nil if not found' do
      lead = CB::Core::Lead.create(token: 'my_token_papa', email: 'some@email.com')
      subject.find('my_token_papa').should eq lead
      subject.find('not_a_token').should   be_nil
    end
  end

  describe '#burn' do
    it 'destroys the lead matching the given token and returns true' do
      CB::Core::Lead.create(token: 'nice_token', email: 'some@mail.io')

      subject.burn('nice_token').should be_true

      CB::Core::Lead.exists?(token: 'nice_token').should be_false
    end
    it 'returns nil if no lead matches the given token' do
      subject.burn('nice_token').should eq false
    end
    it 'returns false if it could not detroy the lead' do
      CB::Core::Lead.create(token: 'nice_token', email: 'some@mail.io')
      CB::Core::Lead.any_instance.stub(:destroy).and_return(false)
      subject.burn('nice_token').should be_false
    end
  end

  describe "invite_all" do
    before do
      CB::Core::Lead.stub(:to_invite).and_return [@first_lead = double(email: 'email1'), @second_lead = double(email: 'email2')]
    end
    it 'sends invitation to every Leads to be invited' do
      subject.should_receive(:invite).with(@first_lead)
      subject.should_receive(:invite).with(@second_lead)

      silence(:stdout) { subject.invite_all }
    end
    context 'when one invitation fails' do
      before do
        subject.stub(:invite).with(@first_lead).and_raise 'some_error'
      end
      it 'proceeds to the next one' do
        subject.should_receive(:invite).with(@second_lead)

        silence(:stdout) { subject.invite_all }
      end
    end
  end

end