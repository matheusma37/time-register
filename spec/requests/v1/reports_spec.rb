require 'rails_helper'

RSpec.describe '/api/v1/reports', type: :request do
  let(:job_id) { 'fake-job-id' }
  let(:mock_status) do
    double(
      'ActiveJob::Status',
      status: :completed,
      progress: 0.5,
      completed?: true
    )
  end

  before do
    allow(mock_status).to receive(:[]).with(:file_url).and_return('http://example.com/file.csv')
    allow(ActiveJob::Status).to receive(:get).with(job_id).and_return(mock_status)
  end

  describe 'GET /status' do
    it 'returns job status and progress' do
      get status_v1_report_url(job_id), as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'process_id' => job_id,
        'status' => 'completed',
        'progress' => 50.0
      )
    end
  end

  describe 'GET /download' do
    it 'redirects to file_url if job is completed' do
      get download_v1_report_url(job_id), as: :json

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to('http://example.com/file.csv')
    end
  end
end
