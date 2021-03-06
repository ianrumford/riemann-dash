class Riemann::Dash
  require 'multi_json'
  require 'fileutils'
  require 'set'

  WS_CONFIG_FILE = "ws/config.json"

  get '/ws' do
    erb :websockets, :layout => false
  end

  get '/ws/config', :provides => 'json' do
    if File.exists? WS_CONFIG_FILE
      send_file WS_CONFIG_FILE, :type => :json
    else
      MultiJson.encode({})
    end
  end

  post '/ws/config' do
    # Read update
    request.body.rewind
    update = MultiJson.decode(request.body.read)

    # Read old config
    if File.exists? WS_CONFIG_FILE
      old = MultiJson.decode File.read WS_CONFIG_FILE
    else
      old = {}
    end

    new = {}

    # Server
    new['server'] = update['server'] or old['server']

    p update['workspaces']
    new['workspaces'] = update['workspaces'] or old['workspaces']

    # Save new config
    FileUtils.mkdir_p 'ws'
    File.open(WS_CONFIG_FILE, 'w') do |f|
      f.write(MultiJson.encode(new))
    end

    # Return current config
    content_type "application/json"
    MultiJson.encode(new)
  end
end
