require 'byebug'

class Static
  attr_reader :app

  MIME_TYPES = {
    .txt: "text/plain",
    .jpg: "image/jpeg",
    .png: "image/png",
    .zip: "application/zip"}
    
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    path = req.path

    if find_file(path)
      show_file(path)
      res
    else
      @app.call(env)
    end
  end

  def find_file(path)
    path.include?("/public")
  end
end

class FileServer

  def call(env)

  end

  def find_file(file_name, res)
    extension = file_name.split(".")[1]
    mime = MIME_TYPE[extension]
    file = File.read(file_name)
    res["Content-type"] = content_type
    res.write(file)
  end
end
