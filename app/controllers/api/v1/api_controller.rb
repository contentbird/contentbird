class API::V1::APIController < ApplicationController

  skip_before_filter :restrict_access

  respond_to :json

private

  def api_response service_result
    success = service_result[0]
    result  = service_result[1]
    respond_to do |format|
      if success
        builder = supports_pagination?(result) ? CB::Api::PaginatedResponse.new(@channel, result, common_params) : CB::Api::SimpleResponse.new(@channel, result, common_params)
        set_custom_headers(builder.response_headers)
        format.json { render text: serialize(builder.response_body) }
      else
        format.json { render json: { message: result[:message]}, status: error_http_status(result[:error]) }
      end
    end
  end

  def common_params
    common_params = {}
    common_params[:context] = params[:context]   if params[:context].present?
    common_params[:page]    = params[:page].to_i if params[:page].present?
    common_params[:per]     = params[:per].to_i  if params[:per].present?
    common_params
  end

  def serialize body
    serialized_body = {}
    body.each {|k, v| serialized_body[k] = serializer_or_model(v) }
    serialized_body.to_json
  end

  def serializer_or_model model
    model.try(:active_model_serializer) ? model.active_model_serializer.new(model) : model
  end

  def set_custom_headers headers_hash
    headers_hash.each { |k, v| headers[k.to_s]=v }
  end

  def supports_pagination? result
    result.respond_to?(:page)
  end

  def error_http_status error_type
    case error_type
    when :not_authorized
      403
    when :not_found
      404
    when :params
      400
    when :exception
      500
    end
  end
end