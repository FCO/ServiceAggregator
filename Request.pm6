use JSON::Pretty;
use HTTP::Client;
class AsyncRequest {
	has HTTP::Client	$.ua .= new;
	has 				$.method = "GET";
	has 				$.url;
	has Pair			@.headers;
	has					$.body;
	has					$.json;
	has Promise			$!prom;

	method TWEAK {
		with $!json {
			$!body = to-json $!json without $!body
		}
	}

	multi method req {
		given $!method {
			when "GET" {
				$!ua.get($!url)
			}
			when "POST" {
				$!ua.post($!url, :data($!json))
			}
		}
	}

	method run {
		without $!prom {
			$!prom = start {
				my $ans = $.req;
				{
					request => {
						:$!method,
						:$!url,
						:@!headers,
						:$!body,
					},
					response => {
						status	=> $ans.status,
						headers	=> $ans.headers,
						body	=> $ans.content,
						json	=> try from-json $ans.content
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
