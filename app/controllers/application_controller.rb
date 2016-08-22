class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # fcd1, 08/22/16: neased on comment above for APIs, will use :null_session
  protect_from_forgery with: :null_session
end
