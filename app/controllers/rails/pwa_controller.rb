module Rails
  class PwaController < ApplicationController
    skip_before_action :authenticate_apoiador!

    def manifest
      render json: {
        name: ENV.fetch("PWA_NAME", "App"),
        short_name: ENV.fetch("PWA_SHORT_NAME", "App"),
        start_url: "/",
        display: "standalone"
      }
    end

    def service_worker
      response.headers["Content-Type"] = "application/javascript"
      render plain: "// service worker placeholder"
    end
  end
end
