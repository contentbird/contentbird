class CB::InMail::Parser
  attr_reader :email, :body, :first_word

  def initialize email
    @email = email
    @body  = email.body
  end

  def parse
    if body.present?
      if valid_url?(first_word)
        content_type_and_params('link', {url: first_word, comment: body_without_first_line})
      end
    end
  end

private
  def first_word
    @first_word ||= body.match(/^(\s)?(?<url>(\S|\d)*)\b/)[0]
  end

  def body_without_first_line
    body.split("\n")[1..-1].join("\n")
  end

  def valid_url? possible_url
    uri = URI.parse(possible_url)
    if uri.kind_of?(URI::HTTP) or uri.kind_of?(URI:HTTPS)
      true
    else
      false
    end
  end

  def content_type_and_params content_type_name, params
    content_type    = CB::Core::ContentType.find_by_name(content_type_name)

    properties_id   = content_type.properties_id_hash
    properties_hash = {}
    params.each do |k, v|
      properties_hash[properties_id[k.to_s].to_s] = v
    end

    [content_type, {title: email.subject}.merge(properties: properties_hash)]
  end
end