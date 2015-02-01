require 'spec_helper'

describe PropagatePropertiesChanges do
  describe "do_perform" do
    it 'finds content type with given id and call set_exportable_properties on all of its contents, passing the content types properties' do
      CB::Core::ContentType.stub(:find)
                           .with(12)
                           .and_return(type = double( properties: (properties = double('properties')),
                                                      contents:   [content1 = double('content 1'),
                                                                   content2 = double('content 2')]))

      properties.stub(:includes).with(:content_type).and_return(['prop1', 'prop2'])

      content1.should_receive(:set_exportable_properties).with(['prop1', 'prop2'])
      content1.should_receive(:save!)

      content2.should_receive(:set_exportable_properties).with(['prop1', 'prop2'])
      content2.should_receive(:save!)

      PropagatePropertiesChanges.do_perform(12)
    end
  end
end