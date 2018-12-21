require 'byebug'

class Static
  attr_reader :app

  MIME_TYPES = {
    ".txt": "text/plain",
    ".jpg": "image/jpeg",
    ".png": "image/png",
    ".zip": "application/zip"
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    path = req.path
    if find_file(path)
      serve_file(path, res)
      res
    else
      @app.call(env)
    end
  end

  def find_file(path)
    path.include?("/public")
  end

  def serve_file(path, res)
    file_name = File.join(File.dirname(__FILE__), "..", path)
    # debugger
    if File.exist?(file_name)
      # debugger
      extension = file_name.split(".").last
      mime = MIME_TYPES[extension]
      file = File.read(file_name)
      res["Content-type"] = mime
      res.write(file)
    else
      res.status = 404
      res.write("File not found")
    end
  end
end
