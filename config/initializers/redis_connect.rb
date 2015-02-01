module RedisConnect
  def self.connect!
    redis_uri = URI.parse(REDIS_PROVIDER_URL)
    Redis.new(driver: :hiredis, host: redis_uri.host, port: redis_uri.port, password: redis_uri.password)
  end
end

Resque.redis = RedisConnect.connect!