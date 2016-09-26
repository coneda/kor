Rails.application.config.session_store(:cookie_store,
  key: '_kor_session',
  secure: false,
  httponly: false
)
