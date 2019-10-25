class UserMailer < ActionMailer::Base

  default :from => Kor.config['maintainer.mail']

  def reset_password(user)
    @user = user
    I18n.locale = locale(@user)
    mail(:to => user.email, :subject => I18n.t("mailer.subjects.password_reset"))
  end

  def account_created(user)
    @user = user
    I18n.locale = locale(@user)
    mail(:to => user.email, :subject => I18n.t("mailer.subjects.account_created"))
  end
  
  def upcoming_expiry(user)
    @user = user
    I18n.locale = locale(@user)
    mail(:to => user.email, :subject => I18n.t("mailer.subjects.upcoming_expiry"))
  end
  
  def download_ready(download)
    @user = download.user
    I18n.locale = locale(@user)
    @download = download
    mail(:to => @user.email, :subject => I18n.t("mailer.subjects.download_ready"))
  end

  
  protected

    def locale(user)
      user.locale.presence ||
      Kor.config['locale'] ||
      I18n.default_locale
    end
end
