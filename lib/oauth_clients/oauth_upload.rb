module OAuthClients
  module OAuthUpload
    include OAuthClients::Multipart
    def oauth_upload(url, options)
      url  = URI.parse(url)
      http = OAuthClients.new_http(url)
    
      req  = Net::HTTP::Post.new(url.request_uri)
      req  = sign_without_pic_field(req, self.access_token, options)
      req  = set_multipart_field(req, options)

      http.request(req)
    end
  
    def sign_without_pic_field(req, access_token, options)
      req.set_form_data(params_without_pic_field(options))
      self.consumer.sign!(req, access_token)
      req
    end

    #mutipart编码：http://www.ietf.org/rfc/rfc1867.txt
    def set_multipart_field(req, params)
      multipart_post = MultipartPost.new
      multipart_post.set_form_data(req, params)
    end

    def params_without_pic_field(options)
      options.except(:pic)
    end
  end
end