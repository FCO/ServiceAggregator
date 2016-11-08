```
perl6 -Ilib -MRequest -e'



my $service = Service.new-load-balance("localhost", 8080);

my $f = Flux.new;
$f.add-dependable: "acc",    Request.new(:$service, :tmpl-body(q"{input: {{input.body}} }"));
$f.add-dependable: "output", Transformation.new: q"{ acc: {{acc.body.input}} }";

$f.input: {body => 42};




say $f.get-output("output");



'
{acc => 42}'

```
