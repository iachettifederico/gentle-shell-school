require "rails_helper"

RSpec.describe "Rails runtime", type: :request do
  it "runs Rails 8.2" do
    expect(Rails.version).to start_with("8.2.")
  end

  it "uses Herb for HTML ERB templates" do
    expect(Rails.application.config.action_view.erb_implementation).to eq(:herb)
  end
end
