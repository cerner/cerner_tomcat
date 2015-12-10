require 'spec_helper'

describe CernerTomcat::RemoteFileBlock do
  let(:remote_file) do
    CernerTomcat::RemoteFileBlock.new('/some/file')
  end

  context 'evaluate block' do
    let(:block) do
      proc do
        source 'my source'
      end
    end

    it 'should update remote file block' do
      remote_file.evaluate(&block)
      expect(remote_file.source).to eq('my source')
      expect(remote_file.file_path).to eq('/some/file')
    end
  end
end
