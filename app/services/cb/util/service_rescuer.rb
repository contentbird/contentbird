class CB::Util::ServiceRescuer
  def initialize instance
    @instance = instance
  end
  def method_missing method, *args, &block
    if @instance.respond_to? method
      begin
        @instance.public_send method, *args, &block
      rescue => e
        error_type = e.is_a?(ActiveRecord::RecordNotFound) ? :not_found : :exception
        [false, {error: error_type, message: e.message}]
      end
    else
      super
    end
  end
end