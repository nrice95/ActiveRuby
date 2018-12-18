require 'rack'
require 'byebug'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  req.post?
  req.params["data"]
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  res.write("#{req.path_info}")
  res.finish
end


Rack::Server.start(
  app: app,
  Port: 3000
)
