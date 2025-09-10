require 'rails_helper'

RSpec.describe "/api/v1/users", type: :request do
  let(:valid_attributes) do
    {
      name: 'Matheus Almeida',
      email: 'matheus.almeida@mail.com'
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      email: 'matheus.almeida'
    }
  end

  describe "GET /index" do
    it "renders a successful response" do
      user = create(:user)
      get v1_users_url, as: :json

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include(a_hash_including('name' => user.name, 'email' => user.email))
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = create(:user)
      get v1_user_url(user), as: :json

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to match(a_hash_including('name' => user.name, 'email' => user.email))
    end

    context "when user is not found" do
      it "renders a JSON response with errors" do
        get v1_user_url(0)

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to match(
          a_hash_including("errors" => [ %(Couldn't find User with 'id'="0") ])
        )
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect { post v1_users_url, params: { user: valid_attributes }, as: :json }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post v1_users_url, params: { user: valid_attributes }, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to match(a_hash_including(**valid_attributes.as_json))
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect { post v1_users_url, params: { user: invalid_attributes }, as: :json }.to change(User, :count).by(0)
      end

      it "renders a JSON response with errors for the new user" do
        post v1_users_url, params: { user: invalid_attributes }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include('errors' => [ "Name can't be blank", "Email is invalid" ])
      end
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          name: 'Matheus Almeida',
          email: 'matheus.almeida@mail.com'
        }
      end

      it "updates the requested user" do
        user = create(:user)

        put v1_user_url(user), params: { user: new_attributes }, as: :json

        user.reload
        expect(user.name).to eq(new_attributes[:name])
        expect(user.email).to eq(new_attributes[:email])
      end

      it "renders a JSON response with the user" do
        user = create(:user)

        put v1_user_url(user), params: { user: new_attributes }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to match(a_hash_including(**new_attributes.as_json))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the user" do
        user = create(:user)

        put v1_user_url(user), params: { user: invalid_attributes }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include('errors' => [ "Name can't be blank", "Email is invalid" ])
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = create(:user)

      expect { delete v1_user_url(user), as: :json }.to change(User, :count).by(-1)
    end
  end
end
