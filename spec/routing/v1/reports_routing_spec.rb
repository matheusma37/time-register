require 'rails_helper'

RSpec.describe V1::ReportsController, type: :routing do
  describe 'routing' do
    it 'routes to #status' do
      expect(get: '/api/v1/reports/1/status').to route_to(
        controller: 'v1/reports', action: 'status', process_id: '1', format: :json
      )
    end

    it 'routes to #download' do
      expect(get: '/api/v1/reports/1/download').to route_to(
        controller: 'v1/reports', action: 'download', process_id: '1', format: :json
      )
    end
  end
end
