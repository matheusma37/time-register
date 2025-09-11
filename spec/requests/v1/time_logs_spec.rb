require 'rails_helper'

RSpec.describe "/api/v1/time_logs", type: :request do
  let(:time_current) { Time.current.change(usec: 0) }
  let(:user) { create(:user) }

  let(:valid_attributes) do
    {
      user_id: user.id,
      clock_in: time_current,
      clock_out: time_current + 1.hour
    }
  end

  let(:invalid_attributes) do
    {
      user_id: nil,
      clock_in: time_current + 1.hour,
      clock_out: time_current
    }
  end

  describe "GET /index" do
    it "renders a successful response" do
      time_log = create(:time_log, user: user)

      get v1_time_logs_url

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include(
        a_hash_including(
          "clock_in" => time_log.clock_in.iso8601(3),
          "clock_out" => time_log.clock_out&.iso8601(3),
          "user_id" => time_log.user_id
        )
      )
    end

    context "when in the user context" do
      it "renders a successful response" do
        first_time_log = create(:time_log, user: user)
        second_time_log = create(:time_log)

        get v1_user_time_logs_url(user_id: user.id)

        expect(response).to be_successful
        expect(JSON.parse(response.body)).to include(
          a_hash_including(
            "clock_in" => first_time_log.clock_in.iso8601(3),
            "clock_out" => first_time_log.clock_out&.iso8601(3),
            "user_id" => first_time_log.user_id
          )
        )
        expect(JSON.parse(response.body)).not_to include(
          a_hash_including(
            "clock_in" => second_time_log.clock_in.iso8601(3),
            "clock_out" => second_time_log.clock_out&.iso8601(3),
            "user_id" => second_time_log.user_id
          )
        )
      end

      context "when partner has no time registers" do
        it "renders a successful response" do
          user = create(:user)

          get v1_user_time_logs_url(user_id: user.id)

          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq([])
        end
      end
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      time_log = create(:time_log)

      get v1_time_log_url(time_log)

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to match(
        a_hash_including(
          "clock_in" => time_log.clock_in.iso8601(3),
          "clock_out" => time_log.clock_out&.iso8601(3),
          "user_id" => time_log.user_id
        )
      )
    end

    context "when time log is not found" do
      it "renders a JSON response with errors" do
        get v1_time_log_url(0)

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to match(
          a_hash_including("errors" => [ %(Couldn't find TimeLog with 'id'="0") ])
        )
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new TimeLog" do
        expect {
          post v1_time_logs_url, params: { time_log: valid_attributes }
        }.to change(TimeLog, :count).by(1)
      end

      it "renders a JSON response with the new time_log" do
        post v1_time_logs_url, params: { time_log: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to match(a_hash_including(**valid_attributes.as_json))
      end
    end

    context "with invalid parameters" do
      it "does not create a new TimeLog" do
        expect {
          post v1_time_logs_url, params: { time_log: invalid_attributes }
        }.to change(TimeLog, :count).by(0)
      end

      it "renders a JSON response with errors for the new time_log" do
        post v1_time_logs_url, params: { time_log: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include(
          'errors' => [ "Clock out must be after clock_in", "User must exist" ]
        )
      end

      context "when already has a time register with clock_out null" do
        it "renders a JSON response with errors for the new time_log" do
          time_log = create(:time_log)
          invalid_attributes.update(clock_out: nil, user_id: time_log.user_id)

          post v1_time_logs_url, params: { time_log: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_content)
          expect(JSON.parse(response.body)).to include(
            'errors' => [ "User already has an open time log" ]
          )
        end
      end
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          clock_in: time_current + 1.hour,
          clock_out: time_current + 2.hours
        }
      end

      it "updates the requested time_log" do
        time_log = create(:time_log)

        put v1_time_log_url(time_log), params: { time_log: new_attributes }

        time_log.reload
        expect(time_log.clock_in).to eq(new_attributes[:clock_in])
        expect(time_log.clock_out).to eq(new_attributes[:clock_out])
      end

      it "renders a JSON response with the time_log" do
        time_log = create(:time_log)

        put v1_time_log_url(time_log), params: { time_log: new_attributes }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to match(a_hash_including(**new_attributes.as_json))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the time_log" do
        time_log = create(:time_log)

        put v1_time_log_url(time_log), params: { time_log: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include('errors' => [ "Clock out must be after clock_in" ])
      end
    end

    context "when changing user_id" do
      let(:unpermitted_attributes) { { user_id: create(:user).id } }

      it "does not update the user_id" do
        time_log = create(:time_log)

        put v1_time_log_url(time_log), params: { time_log: unpermitted_attributes }

        expect(response).to have_http_status(:ok)
        time_log.reload
        expect(time_log.user_id).not_to eq(unpermitted_attributes[:user_id])
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested time_log" do
      time_log = create(:time_log)

      expect { delete v1_time_log_url(time_log) }.to change(TimeLog, :count).by(-1)
    end
  end
end
