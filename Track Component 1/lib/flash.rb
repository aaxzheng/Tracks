require 'json'

class Flash
  def initialize(req)
    @req = req
    cookies = req.cookies["_rails_lite_app_flash"]
    if cookies
      # @cookie = JSON.parse(cookies)
      @now_cookie = JSON.parse(cookies)
    else
      @now_cookie = {}
    end
    @cookie = {}
  end

  def [](key)
    new_key = key.to_s
    @now_cookie[new_key] || @cookie[new_key]
  end

  def []=(key,val)
    @cookie[key.to_s] = val
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash',path: "/", value:@cookie.to_json)
  end

  def now
    @now_cookie
  end
end
