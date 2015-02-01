module UploadHelper

  def resize_url
    IMAGE_RESIZER[:resize_url]
  end

  def resize_ping_img
    IMAGE_RESIZER[:ping_url].present? ? image_tag(IMAGE_RESIZER[:ping_url], size: '0x0') : nil
  end

  def s3_uploader_form(storage_name, options = {}, &block)
    uploader = S3Uploader.new(storage_name, options)
    form_tag(uploader.url, uploader.form_options) do
      uploader.fields.map do |name, value|
        hidden_field_tag(name, value)
      end.join.html_safe + capture(uploader.storage, &block)
    end
  end

  class S3Uploader
    attr_accessor :storage

    def initialize(storage_name, options)
      @storage = Storage.new(storage_name)
      @options = options.reverse_merge(
        id: "fileupload",
        aws_access_key_id: storage.access_key,
        aws_secret_access_key: storage.secret_key,
        bucket: storage.directory,
        acl: "public-read",
        expiration: 5.minutes.from_now,
        max_file_size: storage.max_size,
        as: "file",
        content_type: 'image/jpeg'
      )
    end

    def form_options
      {
        id: @options[:id],
        method: "post",
        authenticity_token: false,
        multipart: true,
        data: {
          post: @options[:post],
          as: @options[:as]
        }
      }
    end

    def fields
      {
        :key => key,
        :acl => @options[:acl],
        :policy => policy,
        :signature => signature,
        "AWSAccessKeyId" => @options[:aws_access_key_id],
        "Content-Type" => @options[:content_type]
      }
    end

    def key
      @key ||= "#{@options[:path_prefix]}/#{SecureRandom.hex}/${filename}"
    end

    def url
      storage.url
    end

    def policy
      Base64.encode64(policy_data.to_json).gsub("\n", "")
    end

    def policy_data
      {
        expiration: @options[:expiration],
        conditions: [
          ["starts-with", "$utf8", ""],
          ["starts-with", "$key", ""],
          ["content-length-range", 0, @options[:max_file_size]],
          {bucket: @options[:bucket]},
          ['starts-with','$Content-Type','image/'],
          {acl: @options[:acl]}
        ]
      }
    end

    def signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha1'),
          @options[:aws_secret_access_key], policy
        )
      ).gsub("\n", "")
    end
  end
end