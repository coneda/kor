class UserMailer < ActionMailer::Base
  def reset_password(user)
    @user = user

    I18n.with_locale locale(@user) do
      mail(
        from: Kor.settings['maintainer_mail'],
        to: user.email,
        subject: I18n.t("mailer.subjects.password_reset")
      )
    end
  end

  def account_created(user)
    @user = user

    I18n.with_locale locale(@user) do
      mail(
        from: Kor.settings['maintainer_mail'],
        to: user.email,
        subject: I18n.t("mailer.subjects.account_created")
      )
    end
  end

  def upcoming_expiry(user)
    @user = user

    I18n.with_locale locale(@user) do
      mail(
        from: Kor.settings['maintainer_mail'],
        to: user.email,
        subject: I18n.t("mailer.subjects.upcoming_expiry")
      )
    end
  end

  def download_ready(download)
    @user = download.user
    @download = download

    I18n.with_locale locale(@user) do
      mail(
        from: Kor.settings['maintainer_mail'],
        to: @user.email,
        subject: I18n.t("mailer.subjects.download_ready")
      )
    end
  end

  protected

    def locale(user)
      user.locale.presence ||
        Kor.settings['default_locale'] ||
        I18n.default_locale
    end
end
