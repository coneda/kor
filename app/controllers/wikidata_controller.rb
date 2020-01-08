class WikidataController < JsonController
  def import
    collections = Kor::Auth.authorized_collections(current_user, :edit)
    @collection = collections.find_by(id: params[:collection_id])
    unless @collection
      render_403 I18n.t('collection_not_writable')
      return
    end

    @kind = Kind.find_by(id: params[:kind_id])
    unless @kind
      render_400 I18n.t('valid_kind_required')
      return
    end

    @import = Kor::Import::WikiData.find(params[:id])
    unless @import
      return_400 I18n.t('valid_wikidata_id_required')
      return
    end
    @import.locale = params[:locale]

    @entity = @import.import(current_user, @collection, @kind)

    if @entity.valid?
      render json: @entity, status: 201
    else
      render json: @entity.errors, status: 422
    end
  end


  protected

    # TODO: why not like the other controllers?
    def authorization
      unless !!current_user
        render json: {message: I18n.t('messages.access_denied')}, status: 403
      end
    end
end
