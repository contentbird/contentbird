def model_id model_or_id
  model_or_id.respond_to?(:id) ? model_or_id.id : model_or_id
end