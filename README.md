Ruby gem to do IRCCat based on SRV records. No longer do you have to
configure shit, that's what DNS is for.


So in your code, just do this:
<pre>
require 'irckitten'

IrcKitten::msg 'Thing broke... that is bad.'
</pre>

And it will look up your IRCCat server, via
'_irccat._tcp.yourdomain.example.org.' (and port), and try and send the
message to there.

Kind of ignores DNS search order and just chops chunks off your hostname
and searches there.

On 1.8.7 will try and use system_timer to do network timeouts. If it isn't
there, or you're on 1.9, then it just uses timeout.
