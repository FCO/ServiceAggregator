use Template::Mustache;
use JSON5::Tiny;
role Dependable {
	has			$.response;

	method run {...}
}

class Service {
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
}

class Transformation does Dependable {
	has Str $.template;

	method new($tmpl) {
		::?CLASS.bless: :template($tmpl)
	}

	method run($data) {
		Template::Mustache.render($!template, $data)
	}
}

class Request does Dependable {
	has Service	$.service is required;
	has Str		$.tmpl-path		= '/';
	has	Str		$.tmpl-headers	= '{}';
	has Str		$.tmpl-body		= '';

	method run($data) {
		my $p-header	= start { from-json Template::Mustache.render($!tmpl-headers,	$data) };
		my $p-body		= start { from-json Template::Mustache.render($!tmpl-body,	$data) };

		my ($header, $body) = await $p-header, $p-body;
		{
			:$header,
			:$body,
		}
	}
}

class Server{...}

class EndPoint {
	use YAMLish;
	has Str			$.name;
	has Str			$.path;
	has Dependable	%!dependables;
	has				%!data;
	has Promise		@!promises;
	has Server		$.server;

	method new(Str $file where *.IO.f, Server :$server) {
		my $conf = load-yaml($file.IO.slurp);
		my $obj = EndPoint.bless(:name($conf<name>), :path($conf<path>), :$server);
		for $conf<requests>.kv -> $name, $data {
			my %pars;
			for <body header path> -> $key {
				if $data{$key}:exists {
					%pars{"tmpl-$key"} = $data{$key}
				}
			}
			my Request $req .= new: :service($obj.server.get-service($data<service>)), |%pars;
			$obj.add-dependable: $name, $req;
		}
		$obj.add-output: Transformation.new: $conf<output>;
		$obj
	}

	method input($input) {
		my %data;
		%data<input> = $input;
		my $p = Promise.new;
		for %!dependables.kv -> $key, $value {
			%data{$key} = start { await $p; $value.run($(%data)) };
		}
		$p.keep;
		|%data
	}

	method add-output(Dependable $obj) {
		%!dependables<__output__> = $obj
	}

	method add-dependable(Str $name, Dependable $obj) {
		%!dependables{$name} = $obj
	}

	method get-output(%data) {
		from-json await %data<__output__>
	}

	method run(:$header, :$body, :$url) {
		@!promises.push: my $ret = start {
			my %data = $.input({
				:$header,
				:$body,
				:$url,
			});
			$.get-output(%data)
		}
		$ret
	}

	method wait-resolve {
		|await @!promises
	}
}

class Server {
	use Path::Map;
	has Service		%!services;
	has EndPoint	%!end-points;
	has 			$!router		= Path::Map.new;

	method lookup(Str $path) {
		$!router.lookup($path).handler
	}

	method new-instance(Str $name, $host, $port) {
		if %!services{$name}:exists {
			%!services{$name}.new-instance: $host, $port;
		} else {
			%!services{$name} = Service.new-instance: $host, $port;
		}
	}

	method new-load-balance(Str $name, $host, $port) {
		if %!services{$name}:exists {
			%!services{$name}.new-instance: $host, $port;
		} else {
			%!services{$name} = Service.new-instance: $host, $port;
		}
	}

	method get-service(Str $name) {
		%!services{$name}
	}

	method add-end-point(Str $file where *.IO.f) {
		my $obj = EndPoint.new: $file, :server(self);
		%!end-points{$obj.name} = $obj;
		$!router.add_handler: $obj.path, $obj
	}

	method list-services {
		%!services.keys
	}

	method list-end-points {
		%!end-points.keys
	}

	method get-end-point(Str $name) {
		%!end-points{$name}
	}
}
