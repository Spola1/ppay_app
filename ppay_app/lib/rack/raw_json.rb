# frozen_string_literal: true

module Rack
  class RawJSON
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Request.new(env)
      if request.path == '/api/v1/simbank/requests' &&
         request.content_type =~ %r{application/json}i &&
         request.user_agent =~ /macrodroid/
        raw_json = env['rack.input'].read
        env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
        env['rack.input'] = StringIO.new("raw_json=#{raw_json}")
      end
      @app.call(env)
    end
  end
end
