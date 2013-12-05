require 'spec_helper'
require_relative '../lib/celes'
require 'uri'

describe Celes do
  let(:url) {'http://www.theredheadproject.com'}
  let(:celes) { Celes.new('url' => url) }
  subject{celes}

  it {should respond_to(:images)}
  it {should respond_to(:snippets)}
  it {should respond_to(:url)}

  it 'should error out when provided no url' do
    expect{Celes.new}.to raise_error(RuntimeError)
  end

  describe 'when provided a valid url' do
    its(:url) {should be == url}

    context 'that causes a redirect' do
      let(:url) {'http://google.com'} # Should redirect the user to http://www.google.com
      let(:celes) { Celes.new('url' => url) }
      subject{celes}

      its(:get_html_content) {should_not be nil}
    end

    describe 'that contains images and text snippets' do
      before do
        subject.stub(:get_html_content) { '<html><body><p>This is a test</p><img src="myimg.png" width="100" height="100"/></body></html>' }
      end

      it 'should have only 1 image' do
        expect(subject.images).to be_an Array
        expect(subject.images.size).to be 1
        expect(subject.images[0]).to be == 'myimg.png'
      end

      it 'should have only 1 snippet' do
        expect(subject.snippets).to be_an Array
        expect(subject.snippets.size).to be 1
        expect(subject.snippets[0]).to be == 'This is a test'
      end
    end
  end
end