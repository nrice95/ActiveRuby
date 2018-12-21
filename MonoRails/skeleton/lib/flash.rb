require 'json'

class Flash
  attr_reader :now

  def initialize(req)
    @cookie = req.cookies["_rails_lite_app_flash"]

    @flash = {}

    @now = @cookie ? JSON.parse(@cookie) : {}
  end

  def []=(key,val)
    # debugger
    @flash[key.to_s] = val
  end

  def [](key)
    # debugger
    self.now[key.to_s] || @flash[key.to_s]
  end

  def store_flash(res)
    res.set_cookie("_rails_lite_app_flash", {path: "/", value: @flash.to_json})
  end

  # def now
    # @cookie ? JSON.parse(@cookie) : {}
  # end
end
