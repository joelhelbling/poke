## Poking About?

This server runs [Poke][gh], a secure message transport
conceptually inspired by the [POKE and PEEK][wk] commands in
the BASIC programming language.

### How to use Poke

To use [Poke][gh], simply POST some data to any URL on this
host and verify an **ok** _(HTTP status 200)_ response.  If data
is already stored at the selected URL, this server will not
store your data and will return a **forbidden** (HTTP status 403)
response.  POST requests to certain reserved URLs (such as the
one for this page) will also not store your data and will return
a **not allowed** (HTTP status 405) response.

A GET request to the same URL will retrieve the same data that
was previously posted there.  The data will be returned with
the same Content-Type that was used to POST the data.  A GET
request to a URL where no data is stored will return a
**not found** (HTTP status 404) response.

Other HTTP methods will, in general, get a **not allowed**
response.

### Data security

[Poke][gh] does not authenticate GET requests.  Consequently,
any data you store on this server should be considered accessible
to the world or should be secured with encryption.  Such
encyption does not fall within the scope of [Poke][gh]'s design:
it simply returns what it has been given, and it does so for any
request from anyone anywhere.

### Storage Quota

[Poke][gh] can be configured by the server owner with Quota
accounts.  These quota accounts stipulate how long any data
items POSTed by the account holder should be maintained before
being deleted.

A quota account holder can send an appropriate token in the
**Authorization** header of a POST request.  The item will
then be stored with an expire date which corresponds to the
settings in the quota'd account.

Quota'd items can also be set to expire after a certain number
of accesses (GET requests) for that item.  For instance, if an
item is POSTED and quota'd for 3 accesses, then after three
GET requests for that item, the item would be marked for
deletion.

To learn more, visit our [website][gh].

[gh]:http://github.com/joelhelbling/poke
[wk]:https://en.wikipedia.org/wiki/PEEK_and_POKE

