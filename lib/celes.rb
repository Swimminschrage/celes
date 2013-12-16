require 'uri'
require 'net/http'
require 'nokogiri'

class Celes
  attr_reader :url

  def initialize(options = {})
    raise 'No URL provided' unless options[:url]

    @url = options[:url]
    @uri = URI(@url)

    parse_options(options)
  end

  def snippets
    return @snippets if @snippets
    make_request
    @snippets
  end

  def images
    return @images if @images
    make_request
    @images
  end

  private

  def parse_options(options)
    # Init defaults as necessary
    @snip_length = options[:snip_length] || 140
    @min_snippet_length = options[:min_snippet_length] || 40

    # Normalize bad options
    @min_snippet_length = 0 if @min_snippet_length < 0
    @snip_length = 0 if @snip_length < 0
  end

  def make_request
    resp = get_html_content
    if resp
      parse_html resp
    else
      raise "Unable to reach #{@url.to_s}"
    end
  end

  def get_html_content
    resp = Net::HTTP.get_response(@uri)
    case resp
      when Net::HTTPSuccess then resp.body
      when Net::HTTPRedirection then
        @url = resp['location']
        @uri = URI(@url)
        get_html_content
    end
  end

  def parse_html (response)
    doc = Nokogiri::HTML.parse(response)

    @images = doc.xpath('/html/body//img/@src').map{ |x| x.value }
    @snippets = doc.xpath('/html/body//*[self::p or self::span]/text()').map{ |x| x.to_s}.keep_if do |str|
      str.strip.length >= @min_snippet_length
    end

    @snippets = @snippets.map { |x| x[0, @snip_length] }
  end
end