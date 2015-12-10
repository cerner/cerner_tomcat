require 'spec_helper'

describe CernerTomcat::TemplateBlock do
  let(:template) do
    CernerTomcat::TemplateBlock.new('/some/file')
  end

  context 'evaluate block' do
    let(:block) do
      proc do
        source 'my source'
        cookbook 'my cookbook'
        variables('key' => 'value')
      end
    end

    it 'should update template block' do
      template.evaluate(&block)
      expect(template.file_path).to eq('/some/file')
      expect(template.source).to eq('my source')
      expect(template.cookbook).to eq('my cookbook')
      expect(template.variables).to eq('key' => 'value')
    end
  end
end
