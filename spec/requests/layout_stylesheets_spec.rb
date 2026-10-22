require "rails_helper"

RSpec.describe "Layout stylesheets", type: :request do
  it "links the compiled Tailwind stylesheet on every locale's home page" do
    %w[/ /es /es-AR].each do |path|
      get path

      expect(response).to have_http_status(:ok)
      hrefs = response.parsed_body.css('link[rel="stylesheet"]').map { |link| link["href"] }
      tailwind = a_string_matching(%r{\A/assets/tailwind-[0-9a-f]+\.css\z})
      expect(hrefs).to include(tailwind), "#{path} links #{hrefs.inspect}"
    end
  end
end
