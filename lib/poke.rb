class Poke

  STORE = {}

  def call(env)
    key = key_from env

    case env['REQUEST_METHOD']
    when 'GET'
      item = STORE[key]
      if item
        render content_type: item[:content_type], content: item[:content]
      else
        render status: 404
      end
    when 'POST'
      STORE[key] = {
        content_type:  env['CONTENT_TYPE'],
        content:       env['rack.input'].readlines }
      render status: 201
    else
      render status: 401
    end
  end

  private

  def key_from(env)
    env['PATH_INFO']
  end

  def render(status: 200, content_type: "text/html", content: [])
    [ status, {"Content-Type" => content_type}, content ]
  end

end

