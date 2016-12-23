use JSON::Tiny;
use ServiceAggregator::Dependable;
use ServiceAggregator::Request;
use ServiceAggregator::Transformation;

class EndPoint {

	use YAMLish;
	has Str			$.name;
	has Str			$.path;
	has Dependable	%!dependables;
	has				%!data;
	has Promise		@!promises;
	has				$.server;
	#has Server		$.server;

	method new(Str $file where *.IO.f, :$server) {
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

	method input(%input) {
		my %data;
		%data<input> = %input;
		my $p = Promise.new;
		for %!dependables.kv -> $key, $value {
			%data{$key} = start {
				await $p;
				my \ret = $value.run($(%data));
				note "ret: ", ret;
				ret
			}
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
		from-json await %data<__output__>;
		CATCH {
			.fail
		}
	}

	method run(:$header = {}, :$body = {}, :$path = {}) {
		@!promises.push: my $ret = start {
			my %data = $.input({
				:$header,
				:$body,
				:$path,
			});
			$.get-output(%data)
		}
		$ret
	}

	method wait-resolve {
		|await @!promises
	}
}
