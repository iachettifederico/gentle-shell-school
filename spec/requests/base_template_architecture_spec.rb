require "rails_helper"

RSpec.describe "Base template setup", type: :request do
  it "eager-loads domain architecture directories" do
    expect(Rails.application.config.eager_load_paths).to include(
      Rails.root.join("app/domain"),
      Rails.root.join("app/adapters"),
      Rails.root.join("app/systems")
    )
  end

  it "serves a basic landing page" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your generated app is ready.")
  end
end
