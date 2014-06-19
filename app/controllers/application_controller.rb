class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  def verified_request?
    if request.content_type == "application/json"
      true
    else
      super()
    end
  end
end
