require 'rails_helper'

RSpec.describe GenerateReportsJob, type: :job do
  let(:user) { create(:user) }
  let(:time_logs) { create_list(:time_log, 5, :with_clock_out, user: user).sort_by(&:clock_in) }
  let(:blob) { double('ActiveStorage::Blob') }
  let(:file_url) { 'http://example.com/file.csv' }
  let(:job) { described_class.new }

  before do
    allow(job).to receive(:progress).and_return(double(total: nil, increment: nil, 'total=': 0))
    allow(job).to receive(:status).and_return({})
    allow(job).to receive(:generate_blob).and_return(blob)
    allow(job).to receive(:generate_file_url).and_return(file_url)
  end

  it 'calls perform and sets file_url in status' do
    expect(User).to receive(:find).with(user.id).and_call_original
    expect(job).to receive(:generate_csv).with(user, time_logs).and_call_original
    expect(job).to receive(:generate_blob).with(an_instance_of(String)).and_return(blob)
    expect(job).to receive(:generate_file_url).with(blob).and_return(file_url)
    expect(job.status).to receive(:[]=).with(:file_url, file_url)

    job.perform(user.id, Date.today.to_s, (Date.today + 1.day).to_s)
  end
end
