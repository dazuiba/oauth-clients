require 'oauth_clients/oauth_upload.rb'
module OAuthClients::Core

  class Base
    attr_accessor :provider, :credentials
    delegate :get, :post, :to => :http_client
    
    def initialize(provider,credentials,options={})
      @provider = provider
      @credentials = credentials
    end
    
    def http_client
      HttpClient.new
    end
    
    
  end
  
  class OAuthBase < Base
    attr_accessor  :consumer_options
    # delegate :oauth_get, :oauth_post, :oauth_put, :oauth_delete, :to => :access_token
    include OAuthClients::OAuthUpload
    
    def initialize(provider,credentials,options={})
      super
      @consumer_options ||= {}
    end
    
    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, credentials["token"], credentials["secret"])
    end
    
    def consumer
      @consumer ||= ::OAuth::Consumer.new(provider.key, provider.secret, consumer_options)
    end
  end
  
  
  class HttpClient
    def post(url,params)
      puts "#{url} => #{params}"
      url = URI(url)
      
      req = Net::HTTP::Post.new(url.path)
      req.form_data = params
      OAuthClients.new_http(url).request(req)
    end
  end
  
  class StringIOWrapper
    def initialize(url, stringio)
      @url = url
      @stringio = stringio
    end
    
    def path
      File.basename(@url)
    end
    
    def read
      @stringio.read
    end
    
    def method_missing(name,*args)
      @stringio.send(name, *args)
    end
  end
  
end
