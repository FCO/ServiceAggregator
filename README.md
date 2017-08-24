```
$ perl6 -Ilib -MServiceAggregator -e'
my Server $s .= new;
$s.new-load-balance("acc", "localhost", 8080);

$s.add-end-point: "bla.yaml";

$s.run(:path</bla>, :body(42)).then: *.result.say;
$s.run(:path</do-not-exists>, :body(55)).then: *.result.say;

sleep 1
'
ret: Promise.new(scheduler => ThreadPoolScheduler.new(initial_threads => 0, max_threads => 16, uncaught_handler => Callable), status => PromiseStatus::Planned)
ret: Promise.new(scheduler => ThreadPoolScheduler.new(initial_threads => 0, max_threads => 16, uncaught_handler => Callable), status => PromiseStatus::Kept)
{body => Not found, code => 404, header => {}}
rendered: {}
rendered: { "input": "42" }
ok: {body => {input => 42}, header => {}}
ret: {body => {input => 42}, header => {}}
ret: { acc: "42" }
```

New test:
```
$ perl6 -I. -MRequest -MJSON::Path -e '


my $req = request :url<http://pudim.com.br>, :method<GET>, json => {:42answer}, :headers[:content-type<application/json>];

my JSON::Path $jp .= new: "\$.response.status";
say $jp.values: $req;
.say for |JSON::Path.new("\$.response.headers").value: $req;

'
(200)
Date => Thu, 24 Aug 2017 02:32:47 GMT
Server => Apache/2.4.25 (Amazon) PHP/5.5.38
Last-Modified => Wed, 23 Dec 2015 01:18:20 GMT
ETag => "353-527867f65e8ad"
Accept-Ranges => bytes
Content-Length => 851
Connection => close
Content-Type => text/html; charset=UTF-8
```
