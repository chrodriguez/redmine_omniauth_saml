# configures public url for our application
OmniAuth.config.full_host = Proc.new do |env|
  url = env["rack.session"]["omniauth.origin"] || env["omniauth.origin"]
  #if no url found, fall back to config/app_config.yml addresses
  if url.blank?
    url = Setting["host_name"]
  #else, parse it and remove both request_uri and query_string
  else
    uri = URI.parse(url)
    url = "#{uri.scheme}://#{uri.host}"
    url << ":#{uri.port}" unless uri.default_port == uri.port
  end
  url
end
