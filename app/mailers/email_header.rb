class EmailHeader
  attr_reader :data

  def initialize receiver_emails=nil, category=nil, receivers_data=nil
    @data = {}
    set_to    receiver_emails unless receiver_emails.nil?
    set_category  category    unless category.nil?
    if receivers_data
      receivers_data.reject{|k,v| k == :emails}.each do |k,v|
        self.add_substitution "%#{k.to_s.singularize}%", v
      end
    end
  end

  def add_substitution tag, values
    if values.count == @data[:to].count
      if @data.key?(:sub)
        @data[:sub][tag] = values
    else
        @data[:sub] = {tag => values}
      end
    else
      raise "Nb of elements in substitution array do not match number of recipient, aborting substitution"
    end
  end

  def as_json
    @data.to_json.gsub(/(["\]}])([,:])(["\[{])/, '\\1\\2 \\3')
  end

  def add_filter_setting filter, setting, value
    @data['filters'] = {}                                 unless @data['filters']
    @data['filters'][filter] = {}                         unless @data['filters'][filter]
    @data['filters'][filter]['settings'] = {}             unless @data['filters'][filter]['settings']
    @data['filters'][filter]['settings'][setting] = value
  end

  private

  def set_category category
    @data[:category] = category
  end

  def set_to receivers
    @data[:to] = receivers
  end
end