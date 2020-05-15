require "rentdynamics/version"

require 'base64'
require 'cgi'
require 'date'
require 'json'
require 'http'
require 'openssl'

module RentDynamics
  class Error < StandardError; end

  class Client
    def initialize(access_key, secret_access_key, development = false)
      @access_key = access_key
      @secret_access_key = secret_access_key
      @base_url = development == false ? 'https://api.rentdynamics.com' : 'https://api-dev.rentdynamics.com'
    end

    def get(endpoint, body)
      headers = get_headers(endpoint, body)
      response = HTTP.headers(headers).get(@base_url + endpoint)
      return response
    end

    def delete(endpoint)
      #not implemented
    end

    def post(endpoint, body)
      headers = get_headers(endpoint, body)
      request_url = @base_url + endpoint
      response = HTTP.headers(headers).post(request_url, :json => body)
      return response
    end

    def put(endpoint)
      headers = get_headers(endpoint, body)
      request_url = @base_url + endpoint
      response = HTTP.headers(headers).put(request_url, :json => body)
      return response
    end

    def get_nonce(timestamp, url, body)
      data = timestamp.encode('utf-8') + url.encode('utf-8')
      if body
        sorted_body = sort_body(body)
        sorted_json = JSON.generate(sorted_body).encode('utf-8')
        data += sorted_json
      end
      return OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), @secret_access_key, data)
    end

    def sort_body(data)
      #
      #   Where possible, sorts all hash and hash-like items by key. Reliably sorts
      #   root-level hashes and nested hashesOrderedDict
      #
      #   Some edge cases may produce unexpected sorting, including but not limited to:
      #       - Strings with JSON, list, or set formatted contents will be converted to hash format
      #       - If contained in a hash, lists and sets will recursively sort each item. Items are not sorted
      #           within the list, but are sorted within themselves
      #               Example: sort_body({\"a\": [{\"c\": 1, \"b\": 2}]}) == {\"a\": [{\"b\": 2. \"c\": 1}]}
      #
      #   :param data: The payload to be sorted before nonce calculation
      #   :return: Sorted data
      #
      if data.is_a? Hash
        sorted_result = Hash.new
        data.sort_by { |k, v| k }.each { |(key, value)|
          if value.is_a? String
            begin
              parsed_value = JSON.parse(value)
              if parsed_value.is_a?(Hash) || parsed_value.is_a?(Array)
                sorted_result[key] = sort_body(parsed_value)
              else
                sorted_result[key] = value
              end
            rescue TypeError
              sorted_result[key] = value
            end
          else
            if value.is_a?(Hash)
              sorted_result[key] = sort_body(value)
            else
              if value.is_a?(Array)
                sorted_result[key] = value.map { |list_item| sort_body(list_item) }
              else
                sorted_result[key] = value
              end
            end
          end
        }
        return sorted_result
      end
      if data.is_a? Array
        s = data.map{|list_item| sort_body(list_item)}
        return s
      end
      return data
    end

    def get_headers(url, body)
      timestamp = (Time.now.to_f * 1000).to_i
      nonce = get_nonce(timestamp.to_s, url, body)
      print(nonce)
      headers = {'x-rd-timestamp' => timestamp.to_s, 'x-rd-api-nonce' => nonce, 'x-rd-api-key' => @access_key,
                 'Content-Type' => 'application/json'}
      return headers
    end
  end


end
