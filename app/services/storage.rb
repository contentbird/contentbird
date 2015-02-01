class Storage
  attr_reader :connection, :credentials, :storage_name, :storage_config

  def initialize storage_name
    @storage_name = storage_name

    @storage_config = STORAGE[@storage_name]

    load_credentials!
    @connection = Fog::Storage.new(@credentials)
  end

  def read key
    @connection.directories.get(directory).files.get(key).body
  end

  def download key, path
    File.open(path, 'wb') {|f| f.write(read(key))}
  end

  def get_attachable key
    if local?
      File.open("#{local_root}/#{directory}/#{key}")
    else
      open(url(key))
    end
  end

  def write key, content
    @connection.directories.get(directory).files.create(key: key, body: content, public: true)
  end

  def write_multipart key, stream
    file = @connection.directories.get(directory).files.new(key: key, body: stream, public: true)
    file.multipart_chunk_size = 5242880 unless self.local?  #5Mb
    file.save
  end

  def delete key
    @connection.directories.get(directory).files.new(:key => key).destroy
  end

  def delete_multiple keys
    @connection.delete_multiple_objects(directory, keys) unless keys.empty?
  end

  def keys_starting_with_path path
    path += '/' unless path.last == '/'
    if local?
      Dir.glob("#{local_root}/#{directory}/#{path}/*").map do |file|
        file[/#{path}.*$/i]
      end
    else
      @connection.directories.get(directory, prefix: path).files.map do |file|
        file.key
      end
    end
  end

  def delete_all_starting_with_path path
    raise 'You cannot DELETE a WHOLE BUCKET' unless path.present? && path != '/'
    delete_multiple keys_starting_with_path(path)
  end

  def self.map_credentials storage_conf
    h = Hash.new

    h[:provider] = storage_conf[:provider]
    if h[:provider] == 'Google'
      h[:google_storage_access_key_id]     = storage_conf[:access_key]  if storage_conf[:access_key]
      h[:google_storage_secret_access_key] = storage_conf[:secret_key]  if storage_conf[:secret_key]
    elsif h[:provider] == 'AWS'
      h[:aws_access_key_id]     = storage_conf[:access_key]             if storage_conf[:access_key]
      h[:aws_secret_access_key] = storage_conf[:secret_key]             if storage_conf[:secret_key]
    end
    h[:local_root] = storage_conf[:local_root]                          if storage_conf[:local_root]
    h[:region]     = storage_conf[:region]                              if storage_conf[:region]
    h
  end

  def load_credentials!
    @credentials = Storage.map_credentials(@storage_config)
  end

  def url key=nil
    if key
      "#{@storage_config[:url]}/#{key}"
    else
      @storage_config[:url]
    end
  end

  def access_key
    @storage_config[:access_key]
  end

  def secret_key
    self.local? ? 'secret' : @storage_config[:secret_key]
  end

  def provider
    @storage_config[:provider]
  end

  def bucket
    @storage_config[:bucket]
  end

  def local_root
    @storage_config[:local_root]
  end

  def directory
    local? ? @storage_config[:folder] : @storage_config[:bucket]
  end

  def local?
    @storage_config[:provider] == 'Local'
  end

  def max_size
    @storage_config[:conditions][:size]
  end

  def post_process
    @storage_config[:post_process]
  end

end

class Fog::Storage::Local::Real
  def delete_multiple_objects directory, keys, options = {}
    keys.each do |key|
      File.delete("#{local_root}/#{directory}/#{key}")
    end
  end

end