unit class Service;
enum ServiceType <instance load-balance>;
class Instance {
	has Str			$.host	= "localhost";
	has uint16		$.port	= 80;
	has ServiceType	$.type	= instance;
}

has Instance @!instances;

method get {
	@!instances.pick
}

multi method new-instance(::?CLASS:U: $host, $port) {
	state $obj = ::?CLASS.new;
	$obj.new-instance: $host, $port;
	$obj
}

multi method new-instance(::?CLASS:D: $host, $port) {
	@!instances.push: Instance.new(:$host, :$port, :type(instance))
}

multi method new-load-balance(::?CLASS:U: $host, $port) {
	state $obj = ::?CLASS.new;
	$obj.new-load-balance: $host, $port;
	$obj
}

multi method new-load-balance(::?CLASS:D: $host, $port) {
	@!instances.push: Instance.new(:$host, :$port, :type(load-balance))
}
