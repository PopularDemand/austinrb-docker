require 'socket'
ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['Served from: ' + ip.ip_address.to_s ]] }
