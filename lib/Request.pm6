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

class Flux {
	has Dependable	%!dependables;
	has				%.data;

	method input($input) {
		%!data<input> = $input;
		my $p = Promise.new;
		%!dependables.pairs.map: -> (:$key, :$value) {
			%!data{$key} = start { await $p; $value.run($(%!data)) };
		}
		$p.keep;
	}

	method add-dependable(Str $name, Dependable $obj) {
		%!dependables{$name} = $obj
	}

	method get-data {
		%!data
	}

	method get-output(Str $name) {
		from-json await $.get-data{$name}
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
	has Str		$.path					= '/';
	has	Str		$.tmpl-headers			= '{}';
	has Str		$.tmpl-body				= '';

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
