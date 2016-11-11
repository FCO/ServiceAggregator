```
$ perl6 -Ilib -MRequest -e'
my Server $s .= new;
$s.new-load-balance("acc", "localhost", 8080);

$s.add-end-point: "bla.yaml";

my $e = $s.lookup: "/bla";


$e.run(:body(42)).then: *.result.say;
$e.run(:body(55)).then: *.result.say;

say $e.wait-resolve
'
{acc => 42}
({acc => 42} {acc => 55})
{acc => 55}
```
