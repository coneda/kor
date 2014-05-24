class GroupsController < ApplicationController
  
  protected
    def zip_download(group, entities)
      unless entities.empty?
        zip_file = Kor::ZipFile.new("#{Rails.root}/tmp/download.zip", 
          :user_id => current_user.id,
          :file_name => "#{group.name}.zip"
        )

        entities.each do |e|
          zip_file.add_entity e
        end
        
        if zip_file.background?
          zip_file.send_later :create_as_download
          flash[:notice] = I18n.t('notices.creating_zip_file')
          redirect_to group
        else
          download = zip_file.create_as_download
          redirect_to download.link
        end
      else
        flash[:notice] = I18n.t('notices.no_entities_in_group')
        redirect_to group
      end
    end
  
end
