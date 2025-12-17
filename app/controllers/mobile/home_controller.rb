module Mobile
  class HomeController < ApplicationController
    skip_before_action :authenticate_apoiador!

    def index
      render plain: "Mobile root"
    end
  end
end
