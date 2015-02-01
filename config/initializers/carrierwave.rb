CarrierWave.configure do |config|
  if STORAGE[:channel_media][:provider] == 'Local'
    config.fog_credentials = {
      :provider               => 'Local',
      :endpoint               => STORAGE[:channel_media][:url],
      :local_root             => STORAGE[:channel_media][:local_root]
    }
    config.fog_directory  = STORAGE[:channel_media][:folder]
  else
    config.fog_credentials = {
      :provider               => STORAGE[:channel_media][:provider],
      :aws_access_key_id      => STORAGE[:channel_media][:access_key],
      :aws_secret_access_key  => STORAGE[:channel_media][:secret_key],
      :region                 => STORAGE[:channel_media][:region]
    }
    config.fog_directory  = STORAGE[:channel_media][:bucket]
    config.fog_public     = true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  end

end