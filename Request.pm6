use SixPM;
use JSON::Pretty;
class AsyncRequest {
	has 		$.method = "GET";
	has 		$.url;
	has Pair	@.headers;
	has			$.body;
	has			$.json;
	has Promise	$!prom;

	method TWEAK {
		with $!json {
			$!body = to-json $!json without $!body
		}
	}

	method run {
		without $!prom {
			# TODO: Do the request
			sleep 5; # just testing
			$!prom = start {
				{
					input	=> {
						:$!method,
						:$!url,
						:@!headers,
						:$!body,
					},
					output	=> {
						headers	=> [],
						body	=> "str",
						json	=> {type => "json"}
					}
				}
			}
		}
		await $!prom
	}
}
sub request(*%pars) is rw is export {
	my AsyncRequest $ar .= new: |%pars;
	Proxy.new:
		FETCH => {
			$ar.run
		},
		STORE => {!!!}
}
