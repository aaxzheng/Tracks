require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    if @already_built == true
      return true
    else
      @already_built = false
      return false
    end
  end

  # Set the response status code and header
  def redirect_to(url)
    @res.set_header('Location',url)
    @res.status = 302
    if already_built_response? == true
      raise "Already Redirected"
    end
    @already_built = true
    @session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response? == true
      raise "Already Redirected"
    end
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built = true
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    rendered = File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb")
    content = ERB.new(rendered).result(binding)
    render_content(content,'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)

  def invoke_action(name)
    if protect_from_forgery? && @req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render(name) unless already_built_response?

    nil
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def prepare_render_or_redirect
      raise "double render error" if already_built_response?
      @already_built_response = true
      @session.store_session(@res)
      flash.store_flash(@res)
    end

    def controller_name
      self.class.to_s.underscore
    end

    def form_authenticity_token
     @token ||= generate_authenticity_token
     res.set_cookie('authenticity_token', value: @token, path: '/')
     @token
   end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end

end
