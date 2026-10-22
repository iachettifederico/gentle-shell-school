require "rails_helper"

RSpec.describe "Course feedback issue form", type: :request do
  it "collects the required feedback fields" do
    form = YAML.safe_load_file(Rails.root.join(".github/ISSUE_TEMPLATE/course-feedback.yml"))
    fields = form.fetch("body").reject { |field| field["type"] == "markdown" }

    expect(fields.pluck("id")).to eq(%w[lesson kind what-happened expected environment])
    expect(fields.map { |field| field.dig("validations", "required") }).to eq([ true, true, true, true, false ])
    expect(form.fetch("labels")).to include("course-feedback")
  end
end
