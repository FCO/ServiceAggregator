use ServiceAggregator::Dependable;
unit class Transformation does Dependable;
use Template::Mustache;

has Str $.template;

method new($tmpl) {
	::?CLASS.bless: :template($tmpl)
}

method run($data) {
	Template::Mustache.render($!template, $data)
}
