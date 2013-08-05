require 'net/http'
require 'uri'

module PythonHelpers
  # Safe HTTP GET
  def self.http_get(url)
    uri = URI(url)
    http = ::Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = ::OpenSSL::SSL::VERIFY_PEER
      http.ca_file = ::File.join(::File.dirname(__FILE__), 'cacert.pem')
    end
    http.get(uri.path).body
  end
end
