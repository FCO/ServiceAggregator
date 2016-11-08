```
perl6 -Ilib -MRequest -e'



my $service = Service.new-load-balance("localhost", 8080);

my $f = Flux.new: {body => 42};
$f.add-dependable: "acc",    Request.new(:$service, :tmpl-body(q"{input: {{input.body}} }"));
$f.add-dependable: "output", Transformation.new: q"{ acc: {{acc.body.input}} }";






say $f.get-output("output");



'
{acc => 42}

```
