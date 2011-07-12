module OAuthClients
  class Provider
    def self.globle_config= (config)
      @globle_config = config
      @all = nil
    end
    
    def self.globle_config
      if @globle_config.nil?
        raise 'OAuthClients::Provider.globle_config = {YOUR_CONFIG_HASH} first!'
      end
      @globle_config
    end
    
    def self.all
      @all||=globle_config.except("base").map{|k,v| self.new(k,globle_config["base"].merge(v))}.sort        
    end
  
    def self.[](key)
      all.find{|e|e.name == key}
    end
  
    attr_accessor :name,:config
  
    def initialize(k,v)
      @name = k
      @config = v
    end
    
    def key
      @config["key"]
    end
    
    def secret
      @config["secret"]
    end
    
    def options
      @config["options"]
    end
    
    def order
      @config["order"]||0
    end
    
    def client(credentials)
      @client = "OAuthClients::Clients::#{self.name.capitalize}".constantize.new(self,credentials)
    end
    
    def <=>(other)
      self.order <=> other.order
    end
  end
  
end