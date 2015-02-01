require "spec_helper"

describe CB::InMail::Parser do
  let(:email)  { FactoryGirl.build :email }

  subject { CB::InMail::Parser.new(email) }

  describe '#parse' do

    context 'given email contains a link with comment' do
      before do
        email.subject = "ContenBird : privacy at last !"
        email.body = <<-EOF
http://contentbird.com/about?param=test
These guys have good values

take a look at this product !
EOF
      end

      it 'returns link content_type + comment and title as additional parameters' do
        link_type = double('link_type', properties_id_hash: {'url' => 10, 'comment' => 20})
        CB::Core::ContentType.stub(:find_by_name).with('link').and_return link_type
        subject.parse.should eq [link_type, { title:   'ContenBird : privacy at last !',
                                                properties: {
                                                  '10' => 'http://contentbird.com/about?param=test',
                                                  '20' => "These guys have good values\n\ntake a look at this product !" }
                                                } ]
      end
    end

  end

end