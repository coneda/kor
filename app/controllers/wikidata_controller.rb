class WikidataController < BaseController
  before_action :authorization

  def preflight
    results = Kor::Import::WikiData.new(params[:locale]).preflight(
      current_user,
      params[:collection],
      params[:id],
      params[:kind]
    )

    if results['success']
      render json: results, status: 201
    else
      render json: results, status: 406
    end
  end

  def import
    results = Kor::Import::WikiData.new(params[:locale]).import(
      current_user,
      params[:collection],
      params[:id],
      params[:kind]
    )

    if results['success']
      render json: results, status: 201
    else
      render json: results, status: 406
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
