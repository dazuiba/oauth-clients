module OAuthClients
    def self.[](key)
      @hash&&@hash[key]
    end

    def self.new_http(url)
      http = if(proxy = self["http_proxy"])
        Net::HTTP.new(url.host, url.port, proxy["host"],proxy["port"])
      else
        Net::HTTP.new(url.host, url.port)
      end

      if $debug
        http.set_debug_output($stderr)
      end
      http
    end

    def self.[]=(k,v)
      @hash||={}
      @hash[k] = v
    end
end

require 'rubygems'
require 'oauth'
require 'mime/types'
require 'net/http'
require 'cgi'
require 'json'
require 'active_support'

require 'oauth_clients/provider'
require 'oauth_clients/multi_part'
require 'oauth_clients/core'
require 'oauth_clients/clients'