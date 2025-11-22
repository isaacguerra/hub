class MensageriaChannel < ApplicationCable::Channel
  def subscribed
    stream_from "mensageria"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
