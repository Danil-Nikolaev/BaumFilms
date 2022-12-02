require 'rails_helper'

RSpec.describe "Films", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/films/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /film" do
    it "returns http success" do
      get "/films/film"
      expect(response).to have_http_status(:success)
    end
  end

end
