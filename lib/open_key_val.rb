require 'net/http'
require 'JSON'
require 'zlib'

class OpenKeyVal
  def self.uri(key = nil)
    URI.parse("http://api.openkeyval.org/#{key}")
  end
  
  def self.get(key)
    response = Net::HTTP.get(uri(key))
    
    begin
      unserialize_data response
    rescue Zlib::DataError => e
      data = JSON.parse response
      if data['error'] == 'not_found'
        raise NameError.new "#{key} not found in openkeyval.org store"
      end
    end
  end
  
  def self.post(key, value)
    compressed_data = serialize_data value
    response = Net::HTTP.post_form uri, key => compressed_data
    JSON.parse response.body
  end
  
  def self.serialize_data(value)
    [Marshal.dump(value)].pack('m')
  end
  
  def self.unserialize_data(serialized_value)
    Marshal.load(serialized_value.unpack('m')[0])
  end
end