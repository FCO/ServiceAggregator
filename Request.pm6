# vim: noai:ts=4:sw=4:et
use JSON::Pretty;
use HTTP::Client;
use v6.d.PREVIEW;
class AsyncRequest {
    has HTTP::Client	$.ua     .= new;
    has					$.method  = "GET";
    has					$.url;
    has					@.headers;
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
                $!ua.get: $!url
            }
            when "POST" {
                $!ua.post: $!url, :data($!json)
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

sub request($name, :%conf, :%data) is rw is export {
    my AsyncRequest $ar .= new: |%conf;
    %data{$name} := Proxy.new:
    FETCH => {
        $ar.run
    },
    STORE => {!!!}
    ;
    %data{$name}
}
