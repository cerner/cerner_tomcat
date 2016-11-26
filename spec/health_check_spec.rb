require 'spec_helper'

describe CernerTomcat::Helpers::HealthCheckBlock do
  let(:health_check) do
    CernerTomcat::Helpers::HealthCheckBlock.new('http://host.com')
  end

  context 'evaluate block' do
    let(:block) do
      proc do
        uri 'http://otherhost.com'
        http_method 'POST'
        backoff [0, 5]
        time_bound 2
      end
    end

    it 'should update health check block' do
      health_check.evaluate(&block)
      expect(health_check.uri).to eq('http://otherhost.com')
      expect(health_check.http_method).to eq('POST')
      expect(health_check.backoff).to eq([0, 5])
      expect(health_check.time_bound).to eq(2)
    end
  end

  context 'evaluate block with defaults' do
    let(:block) do
      proc do
      end
    end

    it 'should use health check block defaults' do
      health_check.evaluate(&block)
      expect(health_check.uri).to eq('http://host.com')
      expect(health_check.http_method).to eq('GET')
      expect(health_check.backoff).to eq([0, 5, 10, 30, 30, 60])
      expect(health_check.time_bound).to eq(3)
    end
  end
end
