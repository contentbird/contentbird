require 'spec_helper'

describe Storage do
  before do
    @gcs_storage_conf = { provider:   'Google',
                            url:        'http://bucket.googleapis.com',
                            access_key: 'YOUR_SECRET_ACCESS_KEY_ID',
                            secret_key: 'YOUR_SECRET_ACCESS_KEY',
                            bucket:     'bucket',
                            conditions: { size: 6000000 },
                            post_process: nil }

    @aws_storage_conf = { provider:   'AWS',
                            url:        'http://bucket.s3.amazonaws.com',
                            access_key: 'YOUR_AWS_ACCESS_KEY_ID',
                            secret_key: 'YOUR_AWS_ACCESS_KEY',
                            bucket:     'bucket',
                            conditions: { size: 3000000 },
                            post_process: :resize_image }

    @gcs_credentials = { provider:                         'Google',
                         google_storage_access_key_id:     'YOUR_SECRET_ACCESS_KEY_ID',
                         google_storage_secret_access_key: 'YOUR_SECRET_ACCESS_KEY'}

    @aws_credentials = { provider:              'AWS',
                         aws_access_key_id:     'YOUR_AWS_ACCESS_KEY_ID',
                         aws_secret_access_key: 'YOUR_AWS_ACCESS_KEY'}
  end

  describe '#new' do
    before do
      Fog.mock!
    end
    it 'should assign @storage with given storage name' do
      with_constants(:STORAGE => {:toto => @gcs_storage_conf}) do
        Storage.new(:toto).storage_name.should eq :toto
      end
    end

    it 'should create a FOG connection for @storage and @credentials' do
      with_constants(:STORAGE => {:toto => @gcs_storage_conf}) do
        Storage.any_instance.stub(:credentials).and_return(@gcs_credentials)
        s = Storage.new(:toto)
        s.connection.class.should eq Fog::Storage::Google::Mock
      end
    end

    it "should load credentials of the given storage in @credentials, mapping to Google fog credentials" do
      with_constants(:STORAGE => {:toto => @gcs_storage_conf}) do
        s = Storage.new(:toto)
        s.credentials.should eq @gcs_credentials
      end
    end
    it "should load credentials of the given storage in @credentials, mapping to AWS fog credentials" do
      with_constants(:STORAGE => {:toto => @aws_storage_conf}) do
        s = Storage.new(:toto)
        s.credentials.should eq @aws_credentials
      end
    end
    after do
      Fog.unmock!
    end
  end

  describe '#file access' do
    before do
      tmp_dir = "#{Rails.root}/#{STORAGE[:content_image][:local_root]}/#{STORAGE[:content_image][:folder]}"
      @uploaded_file_path = tmp_dir + "/uploaded_file_key.jpg"
      FileUtils::mkdir_p(tmp_dir) unless FileTest::directory?(tmp_dir)
      File.open(@uploaded_file_path, 'wb') {|f| f.write("body") }
      @storage = Storage.new(:content_image)
    end
    describe '#read' do
      it "should access the file and return its content" do
        @storage.read('uploaded_file_key.jpg').should eq 'body'
      end
    end
    describe '#download' do
      it 'should create a file at the given path, and fill it with the S3 file content' do
        @storage.download('uploaded_file_key.jpg', "#{Rails.root}/tmp/my_downloaded_file.jpg")
        File.read("#{Rails.root}/tmp/my_downloaded_file.jpg").should eq "body"
      end
    end
    describe '#get_attachable' do
      it "should return a file object if storage is local" do
        @storage.get_attachable('uploaded_file_key.jpg').class.to_s.should eq 'File'
        @storage.get_attachable('uploaded_file_key.jpg').read.should eq 'body'
      end
      it "should return an url object if storage is not local" do
        @storage.stub(:local?).and_return(false)
        @storage.stub(:open).with(@storage.url('uploaded_file_key.jpg')).and_return 'a file'
        @storage.get_attachable('uploaded_file_key.jpg').should eq 'a file'
      end
    end
    describe '#write' do
      it "should write the given content to the given filename" do
        @storage.write('written_file_key.jpg', 'my new body')
        @storage.read('written_file_key.jpg').should eq 'my new body'
      end
    end
    describe '#write_multipart' do
      it "should write the given stream to the given filename" do
        @storage.write_multipart('written_file_key.jpg', 'my loooooooong body')
        @storage.read('written_file_key.jpg').should eq 'my loooooooong body'
      end
    end
    describe '#delete' do
      it 'should remove the file form storage' do
        expect{@storage.delete('uploaded_file_key.jpg')}.to change{(File.exist?(@uploaded_file_path))}.from(true).to(false)
      end
    end
  end

  describe '#file access in cloud' do

    before do
      @storage = nil
      with_constants(:STORAGE => {:toto => @aws_storage_conf}) do
        @storage = Storage.new(:toto)
      end
    end

    describe '#keys_starting_with_path' do
      before do
        @storage.connection.should_receive(:directories).and_return(directories = double('directories'))
        directories.should_receive(:get)
                   .with('bucket', {prefix: '2/37/'})
                   .and_return(double('files getter', files: [
                                                                OpenStruct.new(key: '2/37/dir/file.gif'),
                                                                OpenStruct.new(key: '2/37/dir2/file2.jpg')
                                                              ]
                                      )
                              )
      end
      it 'returns the keys of all files starting with the given path in the storage bucket' do
        @storage.keys_starting_with_path('2/37/').should eq ['2/37/dir/file.gif', '2/37/dir2/file2.jpg']
      end

      it 'add a slash at the end of the path if none is given' do
        @storage.keys_starting_with_path('2/37').should eq ['2/37/dir/file.gif', '2/37/dir2/file2.jpg']
      end

    end

    describe '#delete_all_starting_with_path' do
      it 'calls delete_multiple passing all keys starting with the given path' do
        @storage.stub(:keys_starting_with_path).with('2/37/').and_return ['2/37/dir/file.gif', '2/37/dir2/file2.jpg']
        @storage.should_receive(:delete_multiple).with(['2/37/dir/file.gif', '2/37/dir2/file2.jpg'])

        @storage.delete_all_starting_with_path('2/37/')
      end
      it 'for security purposes you have to give a folder as parameter' do
        @storage.should_receive(:delete_multiple).never
        expect{@storage.delete_all_starting_with_path('')}.to raise_error('You cannot DELETE a WHOLE BUCKET')
        expect{@storage.delete_all_starting_with_path(nil)}.to raise_error('You cannot DELETE a WHOLE BUCKET')
        expect{@storage.delete_all_starting_with_path('/')}.to raise_error('You cannot DELETE a WHOLE BUCKET')
      end
    end

    describe '#delete_multiple' do
      it 'calls Fog delete_multiple_objects methods, passing the given keys array' do
        @storage.connection.should_receive(:delete_multiple_objects).with('bucket', ['2/37/dir/file.gif', '2/37/dir2/file2.jpg'])
        @storage.delete_multiple(['2/37/dir/file.gif', '2/37/dir2/file2.jpg'])
      end
      it 'doesnt tell Fog to delete files if there is no file to delete in the keys array' do
        @storage.connection.should_receive(:delete_multiple_objects).never
        @storage.delete_multiple([])
      end
    end
  end


  describe '#self.map_credentials' do
    it 'should load storage credentials from environment and adapt to FOG params' do
      Storage.map_credentials(@gcs_storage_conf).should eq({:provider                         => 'Google',
                                                              :google_storage_access_key_id     => 'YOUR_SECRET_ACCESS_KEY_ID',
                                                              :google_storage_secret_access_key => 'YOUR_SECRET_ACCESS_KEY'})
    end
  end

  describe '#load_credentials!' do
    it 'should assign the mapped credentials of the given storage to the @credentials attribute' do
      with_constants(:STORAGE => {:test_storage => @gcs_storage_conf}) do
        s = Storage.new(:test_storage)
        Storage.should_receive(:map_credentials).with(@gcs_storage_conf).and_return('my_mapped_credentials')
        s.load_credentials!
        s.credentials.should eq 'my_mapped_credentials'
      end
    end
  end

  describe '#accessors' do
    it 'should access to the url, access_key and bucket through their corresponding accessors' do
      with_constants(:STORAGE => {:test_storage => @gcs_storage_conf}) do
        s = Storage.new(:test_storage)
        s.url.should eq 'http://bucket.googleapis.com'
        s.url('toto.jpg').should eq 'http://bucket.googleapis.com/toto.jpg'
        s.access_key.should eq 'YOUR_SECRET_ACCESS_KEY_ID'
        s.bucket.should eq 'bucket'
        s.provider.should eq 'Google'
        s.max_size.should eq 6000000
        s.secret_key.should eq 'YOUR_SECRET_ACCESS_KEY'
        s.post_process.should be_nil
      end

      with_constants(:STORAGE => {:test_storage => @aws_storage_conf}) do
        s = Storage.new(:test_storage)
        s.post_process.should eq :resize_image
      end
    end
  end

end