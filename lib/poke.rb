
# TODO:
# - back STORE with durable storage (disk, nosql, kyoto)
# - default expiration of records to (whichever comes first):
#   - 60 minutes
#   - first retrieval
# - accept an authorized token header which unlocks custom functionality
# - when a POST presents an auth token, it may also set headers for:
#   - n where: expire record on datetime n (up to one year, date/times in UTC)
#   - n where: delete after n retrievals

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

