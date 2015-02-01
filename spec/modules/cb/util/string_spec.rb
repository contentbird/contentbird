describe CB::Util::String do

  subject {CB::Util::String}

  describe '#transliterate' do
    it 'remove unwanted caracters from string' do
      subject.transliterate("Say mY  F*$€32 NAME ! ").should eq 'say-my-f-32-name'
    end
  end
end