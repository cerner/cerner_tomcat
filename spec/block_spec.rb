require 'spec_helper'

describe CernerTomcat::Block do
  let(:block) do
    CernerTomcat::Block.new
  end

  before(:each) do
    @value = 0
  end

  def value(v)
    @value = v
  end

  context 'evaluate block' do
    let(:code) do
      proc do
        value 1
      end
    end

    it 'evaluates the code' do
      block.evaluate(&code)
      expect(@value).to eq(1)
    end
  end
end
