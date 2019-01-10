require 'json'

class Session
  def initialize(req)
    @req = req
    cookie = req.cookies["_rails_lite_app"]
    if cookie
      @cookie = JSON.parse(cookie)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    attributes = {path: "/", value:@cookie.to_json}
    res.set_cookie('_rails_lite_app',attributes)
  end
end
