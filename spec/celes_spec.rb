require 'spec_helper'
require_relative '../lib/celes'
require 'uri'

describe Celes do
  let(:url) {'http://www.theredheadproject.com'}
  let(:celes) { Celes.new(url: url) }
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
      let(:celes) { Celes.new(url: url) }
      subject{celes}

      its(:get_html_content) {should_not be nil}
    end

    describe 'that contains images and text snippets' do
      before do
        subject.stub(:get_html_content) { '<html><body><p>This is a test for some text that should be long enough</p><img src="myimg.png" width="100" height="100"/></body></html>' }
      end

      it 'should have only 1 image' do
        expect(subject.images).to be_an Array
        expect(subject.images.size).to be 1
        expect(subject.images[0]).to be == 'myimg.png'
      end

      it 'should have only 1 snippet' do
        expect(subject.snippets).to be_an Array
        expect(subject.snippets.size).to be 1
        expect(subject.snippets[0]).to be == 'This is a test for some text that should be long enough'
      end
    end

    # Marking these tests as pending until I can figure out how to get Nokogiri to parse html that has img and p tags
    # in the head.
    describe 'only parses images and text snippets within the body' do
      let(:url) {'http://www.theredheadproject.com'}
      let(:nobody) { Celes.new(url: url) }
      subject {nobody}
      before do
        nobody.stub(:get_html_content).and_return '<html><head><p>This is a test for some text that should be long enough</p><img src="myimg.png" width="100" height="100"/></head><body><p>Body Text</p></body></html>'
      end

      xit 'should have no images' do
        expect(subject.images).to be_an Array
        subject.images.each { |img| puts img }
        expect(subject.images.size).to be 0

      end

      xit 'should have no snippets' do
        expect(subject.snippets).to be_an Array
        expect(subject.snippets.size).to be 0
      end
    end

    describe 'can take options' do
      context ':min_snippet_length' do
        it 'defaults to 40 characters' do
          c = Celes.new(url: url)
          c.stub(:get_html_content).and_return '<p>Not 40 characters</p><p>Definitely 40 characters long test here!</p>'

          expect(c.snippets.size).to be 1
          expect(c.snippets[0]).to eq 'Definitely 40 characters long test here!'
        end

        it 'less than 0 defaults to 0' do
          c = Celes.new(url: url, min_snippet_length: -10)
          c.stub(:get_html_content).and_return '<p>Not 40 characters</p><p>Definitely 40 characters long test here!</p>'

          expect(c.snippets.size).to be 2
          expect(c.snippets[0]).to eq 'Not 40 characters'
          expect(c.snippets[1]).to eq 'Definitely 40 characters long test here!'
        end

        it 'can be set to any int 0 or greater' do
          c = Celes.new(url: url, min_snippet_length: 17)
          c.stub(:get_html_content).and_return '<p>Not 40 characters</p><p>Definitely 40 characters long test here!</p>'

          expect(c.snippets.size).to be 2
          expect(c.snippets[0]).to eq 'Not 40 characters'
          expect(c.snippets[1]).to eq 'Definitely 40 characters long test here!'
        end

        it 'can be set to 0' do
          c = Celes.new(url: url, min_snippet_length: 0)
          c.stub(:get_html_content).and_return '<p>A</p><p>Not 40 characters</p><p>Definitely 40 characters long test here!</p>'

          expect(c.snippets.size).to be 3
          expect(c.snippets[0]).to eq 'A'
        end
      end

      context ':snip_length' do
        let(:text59) { 'C' * 59 }
        let(:text140) { 'A' * 140 }
        let(:text150) { 'B' * 150 }

        before {Celes.any_instance.stub(:get_html_content).and_return "<p>#{text59}</p><p>#{text140}</p><p>#{text150}</p>"}

        it 'defaults to 140 characters' do
          c = Celes.new(url: url)

          expect(c.snippets.size).to be 3
          expect(c.snippets[0]).to eq text59
          expect(c.snippets[1]).to eq text140
          expect(c.snippets[2]).to eq text150[0, 140]
        end

        it 'defaults to 0 when a negative value is provided' do
          c = Celes.new(url: url, snip_length: -100)

          expect(c.snippets.size).to be 3
          expect(c.snippets[0]).to be_empty
          expect(c.snippets[1]).to be_empty
        end

        it 'can be set to be any value greater than 0' do
          c = Celes.new(url: url, snip_length: 60)

          expect(c.snippets.size).to be 3
          expect(c.snippets[0]).to eq text59
          expect(c.snippets[1]).to eq text140[0, 60]
          expect(c.snippets[2]).to eq text150[0, 60]
        end
      end
    end
  end
end