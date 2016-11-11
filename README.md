```
$ perl6 -Ilib -MRequest -e'
my Server $s .= new;
$s.new-load-balance("acc", "localhost", 8080);

$s.add-end-point: "bla.yaml";

$s.run(:path</bla>, :body(42)).then: *.result.say;
$s.run(:path</do-not-exists>, :body(55)).then: *.result.say;

sleep 1
'
{body => Not found, code => 404, header => {}}
{acc => 42}
```
