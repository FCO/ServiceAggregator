# vim: noai:ts=4:sw=4:et
grammar Request::Path {
    token TOP               { <root> <child-list>   }

    token child-list        { <child>*              }

    proto token child       { *                     }
    token child:sym<sw>     { <sep> <word>          }
    token child:sym<b>      { <brack>               }

    token root              { '$' <word>            }
    token word              { \w+                   }
    regex str               { .+                    }
    token int               { \d+                   }

    proto token sep         { *                     }
    token sep:sym<dot>      { '.'                   }
    token sep:sym<ddot>     { '..'                  }

    proto token brack       { *                     }
    token brack:sym<int>    { '[' ~ ']' <int>       }
    token brack:sym<sstr>   { '["' ~ '"]' <str>     }
    token brack:sym<dstr>   { "['" ~ "']" <str>     }
}

class Request::Path::Action {
    method brack:sym<dstr>($/) { make $<str>.made                                           }
    method brack:sym<sstr>($/) { make $<str>.made                                           }
    method brack:sym<int> ($/) { make $<int>.made                                           }

    method sep:sym<ddot>  ($/) { make "rec"                                                 }
    method sep:sym<dot>   ($/) { make "child"                                               }

    method int            ($/) { make +$/                                                   }
    method str            ($/) { make ~$/                                                   }
    method word           ($/) { make ~$/                                                   }
    method root           ($/) { make $<word>.made                                          }

    method child:sym<b>   ($/) { make {type => "child", name => $<brack>.made}              }
    method child:sym<sw>  ($/) { make {type => $<sep>.made, name => $<word>.made}           }

    method child-list     ($/) { make $<child>>>.made                                       }

    method TOP            ($/) { make {root => $<root>.made, chain => $<child-list>.made}   }
}


