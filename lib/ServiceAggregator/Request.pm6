use Template::Mustache;
use JSON::Tiny;
use ServiceAggregator::Dependable;
unit class Request does Dependable;
has			$.service is required;
#has Service	$.service is required;
has Str		$.tmpl-path		= '{}';
has	Str		$.tmpl-headers	= '{}';
has Str		$.tmpl-body		= '';

method run(%data) {
	my $header	= $.render-json($!tmpl-headers,   %data);
	my $body	= $.render-json($!tmpl-body,      %data);
	if any($header, $body) ~~ Failure {
		note "error: ", {:$header, :$body}
	} else {
		note "ok: ", {:$header, :$body}
	}
	{
		:$header,
		:$body,
	}
}

method render-json($template, %data) {
	my Str \rendered = Template::Mustache.render($template, %data);
	note "rendered: {rendered}";
	return from-json rendered;
	CATCH {
		note "catch: $_";
		return fail $_
	}
}
