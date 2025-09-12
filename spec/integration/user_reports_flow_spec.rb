require 'rails_helper'

RSpec.describe 'User reports integration', type: :request do
  let(:user_params) { { user: { name: 'Test User', email: 'test@example.com' } } }
  let(:updated_params) { { user: { name: 'Updated User', email: 'updated@example.com' } } }
  let(:time_log_params) do
    [
      { clock_in: '2025-09-10T08:00:00Z', clock_out: '2025-09-10T17:00:00Z' },
      { clock_in: '2025-09-11T08:00:00Z', clock_out: '2025-09-11T17:00:00Z' }
    ]
  end
  let(:job_id) { 'fake-job-id' }
  let(:mock_status) do
    double(
      'ActiveJob::Status',
      status: :completed,
      progress: 1.0,
      completed?: true
    )
  end

  before do
    allow(GenerateReportsJob).to receive_message_chain(:perform_later, :job_id).and_return(job_id)
    allow(ActiveJob::Status).to receive(:get).with(job_id).and_return(mock_status)
    allow(mock_status).to receive(:[]).with(:file_url).and_return('http://example.com/file.csv')
  end

  it 'creates, updates user, creates time_logs, generates, checks report status and downloads the report' do
    post v1_users_url, params: user_params, as: :json
    expect(response).to have_http_status(:created)
    user_id = JSON.parse(response.body)['id']

    put v1_user_url(user_id), params: updated_params, as: :json
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)['name']).to eq('Updated User')

    time_log_params.each do |params|
      post v1_time_registers_url, params: { time_register: params.merge(user_id: user_id) }, as: :json
      expect(response).to have_http_status(:created)
    end

    post reports_v1_user_url(user_id), params: { start_date: '2025-09-10', end_date: '2025-09-11' }, as: :json
    expect(response).to have_http_status(:accepted)
    body = JSON.parse(response.body)
    expect(body['process_id']).to eq(job_id)
    expect(body['status']).to eq('completed')

    get status_v1_report_url(job_id), as: :json
    expect(response).to have_http_status(:ok)
    status_body = JSON.parse(response.body)
    expect(status_body['process_id']).to eq(job_id)
    expect(status_body['status']).to eq('completed')
    expect(status_body['progress']).to eq(100.0)

    get download_v1_report_url(job_id), as: :json
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to('http://example.com/file.csv')
  end

  it 'returns error when creating a second time_log with null clock_out for the same user' do
    post v1_users_url, params: user_params, as: :json
    expect(response).to have_http_status(:created)
    user_id = JSON.parse(response.body)['id']

    post(
      v1_time_registers_url,
      params: {
        time_register: { user_id: user_id, clock_in: '2025-09-13T08:00:00Z', clock_out: nil }
      },
      as: :json
    )
    expect(response).to have_http_status(:created)

    post(
      v1_time_registers_url,
      params: {
        time_register: { user_id: user_id, clock_in: '2025-09-14T08:00:00Z', clock_out: nil }
      },
      as: :json
    )
    expect(response).to have_http_status(:unprocessable_content).or have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)['errors']).to be_present
  end
end
