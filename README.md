```
perl6 -Ilib -MRequest -e'



my $service = Service.new-load-balance("localhost", 8080);

my $e = EndPoint.new: "bla.yaml";


say $e.run: :body(42);
say $e.run: :body(55);


'
{acc => 42}
{acc => 55}
```
