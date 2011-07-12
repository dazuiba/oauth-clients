require 'open-uri'
module OAuthClients::Clients
  
  class Tsina < OAuthClients::Core::OAuthBase
    def initialize(provider,credentials,options={})
        super
        self.consumer_options = {
          :site               => 'http://api.t.sina.com.cn',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authorize',
          :realm              => provider.config["realm"]
        }
    end
    
    def say(content,options={})
      options.merge!(:status => content)
      puts options.inspect
      if path = options['image_path']||options['image_url']
        stream = open(path)
        if stream.is_a?(StringIO)
          stream = OAuthClients::Core::StringIOWrapper.new(path, stream)
        end
        options.merge!(:pic => stream)
        oauth_upload("http://api.t.sina.com.cn/statuses/upload.json", options.to_options)
      else
        self.access_token.post("http://api.t.sina.com.cn/statuses/update.json", options)
      end
    end
  end

  class Douban < OAuthClients::Core::OAuthBase
    
    def initialize(provider,credentials,options={})
        super
        self.consumer_options = {
          :signature_method   => "HMAC-SHA1",
          :site               => "http://www.douban.com",
          :scheme             => :header,
          :request_token_path => '/service/auth/request_token',
          :access_token_path  => '/service/auth/access_token',
          :authorize_path     => '/service/auth/authorize',
          :realm              => provider.config["realm"]
        }
        
    end
    
  
    def say(content, options={})
      self.access_token.post("http://api.douban.com/miniblog/saying", <<-XML, {"Content-Type" =>  "application/atom+xml"})
        <?xml version='1.0' encoding='UTF-8'?>
        <entry xmlns:ns0="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/">
        <content>#{content}</content>
        </entry>
        XML
    end
  end
  
  class Renren < OAuthClients::Core::Base
    def initialize(provider,credentials,options={})
        super
    end
    
    def say(content,options={})
      hash =  {"access_token" =>  credentials["token"],
              "method" => 'status.set',
              "call_id" => 1,
              "v" =>"1.0",
              "status" => content}
      hash["sig"] = compute_sig(hash)
      self.post("http://api.xiaonei.com/restserver.do",hash)
    end
    
  private
    def compute_sig(params)
       str = params.collect {|k,v| "#{k}=#{v}"}.sort.join("") + provider.secret
       str = Digest::MD5.hexdigest(str)
    end
  end
  
  
  class Tqq < OAuthClients::Core::OAuthBase
    def initialize(provider,credentials,options={})
        super
        self.consumer_options = {
          :site => "https://open.t.qq.com",
          :request_token_path  => "/cgi-bin/request_token",
          :access_token_path   => "/cgi-bin/access_token",
          :authorize_path      => "/cgi-bin/authorize",
          :http_method         => :get,
          :scheme              => :query_string,
          :nonce               => nonce,
          :realm               => provider.config["realm"]
        }
        
    end
    
    
    def say(content, options = {})
      options.merge!(:content => content)
      self.access_token.post("http://open.t.qq.com/api/t/add", options)
    end
    
    def nonce
      Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
    end
  end
end