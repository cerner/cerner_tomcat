require 'spec_helper'

describe CernerTomcat::CookbookFileBlock do
  let(:cookbook_file) do
    CernerTomcat::CookbookFileBlock.new('/some/file')
  end

  context 'evaluate block' do
    let(:block) do
      proc do
        source 'my source'
        cookbook 'my cookbook'
      end
    end

    it 'should update cookbook file block' do
      cookbook_file.evaluate(&block)
      expect(cookbook_file.file_path).to eq('/some/file')
      expect(cookbook_file.source).to eq('my source')
      expect(cookbook_file.cookbook).to eq('my cookbook')
    end
  end
end
