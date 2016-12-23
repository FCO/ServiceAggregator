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
