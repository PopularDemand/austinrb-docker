require 'socket'
require 'redis'
redis = Redis.new(:host => "redis", :port => 6379, :db => 1)

begin
	incr = redis.incr "counter"
	incr = redis.get "counter"
rescue
	incr = "Redis not available"
end

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['Counter:' + incr.to_s + ' Served from: ' + ip.ip_address.to_s ]] }
