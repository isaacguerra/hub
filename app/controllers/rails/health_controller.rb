module Rails
  class HealthController < ApplicationController
    skip_before_action :authenticate_apoiador!

    def show
      head :ok
    end
  end
end
