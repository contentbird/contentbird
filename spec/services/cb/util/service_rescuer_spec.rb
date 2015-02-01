describe CB::Util::ServiceRescuer do

  class Service
    def working_method myparam
      "instance says #{myparam}"
    end
    def raises_not_found
      raise ActiveRecord::RecordNotFound.new("Couldn't find CB::Core::Content with id=0")
    end
    def raises_some_exception
      raise "some exception"
    end
  end

  subject       { CB::Util::ServiceRescuer.new(Service.new) }

  describe '#method_missing' do

    it '#forwards method calls to its instance and returns the result in no error raised' do
      subject.working_method('hello decorator').should eq 'instance says hello decorator'
    end

    it '#catches the record not found errors and returns a proper service splat' do
      subject.raises_not_found.should eq [false, {error: :not_found, message: "Couldn't find CB::Core::Content with id=0"}]
    end

    it '#catches all errors and returns a proper service splat' do
      subject.raises_some_exception.should eq [false, {error: :exception, message: "some exception"}]
    end

  end
end