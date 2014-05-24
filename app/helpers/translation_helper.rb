module TranslationHelper
  
  def mime_human_name(mime)
    I18n.t(mime, :scope => :mimes)
  end
  
  def model_specifier(model, count = :one)
    I18n.t(:specifier, :scope => [ :activerecord, :models, model.to_s.underscore], :count => count)
  end
  
end
