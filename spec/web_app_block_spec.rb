require 'spec_helper'

describe CernerTomcat::WebAppBlock do
  let(:web_app) do
    CernerTomcat::WebAppBlock.new('my web app')
  end

  context 'evaluate block' do
    let(:block) do
      proc do
        source 'my source'

        cookbook_file '/some/cookbook_file' do
          source 'cookbook_file source'
          cookbook 'cookbook_file cookbook'
        end

        remote_file '/some/remote_file' do
          source 'remote_file source'
        end

        template '/some/template' do
          source 'template source'
          cookbook 'template cookbook'
          variables('key' => 'value')
        end
      end
    end

    it 'should update web_app block' do
      web_app.evaluate(&block)
      expect(web_app.name).to eq('my web app')
      expect(web_app.source).to eq('my source')

      expect(web_app.cookbook_files.size).to eq(1)
      expect(web_app.cookbook_files.first.file_path).to eq('/some/cookbook_file')
      expect(web_app.cookbook_files.first.source).to eq('cookbook_file source')
      expect(web_app.cookbook_files.first.cookbook).to eq('cookbook_file cookbook')

      expect(web_app.remote_files.size).to eq(1)
      expect(web_app.remote_files.first.file_path).to eq('/some/remote_file')
      expect(web_app.remote_files.first.source).to eq('remote_file source')

      expect(web_app.templates.size).to eq(1)
      expect(web_app.templates.first.file_path).to eq('/some/template')
      expect(web_app.templates.first.source).to eq('template source')
      expect(web_app.templates.first.cookbook).to eq('template cookbook')
      expect(web_app.templates.first.variables).to eq('key' => 'value')
    end
  end
end
