use Template::Mustache;
use ServiceAggregator::Service;
use ServiceAggregator::EndPoint;
use ServiceAggregator::HardCodedEndPoint;
use Path::Map;
unit class Server;
has Service				%!services;
has EndPoint			%!end-points;
has 					$!router		=	Path::Map.new;
has HardCodedEndPoint	$!not-found		.=	new: data => {"code" => 404, "body" => "Not found", "header" => {}};

method lookup(Str $path) {
	$!router.lookup($path)
}

method run(Str :$path, :$header, :$body) {
	my $match	= $.lookup($path);
	my $to-run;
	my %vars;
	with $match {
		%vars	= $match.variables;
		$to-run = $match.handler
	} else {
		$to-run = $!not-found
	}
	my \ret = $to-run.run(:path(%vars), :$header, :$body);
	say "ret1: ", ret;
	ret
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
