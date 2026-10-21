# Plain-text entry point for agents: what the school is and how to use its API.
class LlmsController < ApplicationController
  def show
    render plain: render_to_string(template: "llms/show", formats: [ :text ], locals: { origin: request.base_url })
  end
end
