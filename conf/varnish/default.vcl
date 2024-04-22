vcl 4.0;
# set default backend if no server cluster specified
backend default {
    .host = "fastcgi";
    .port = "8080";
    # .port = "80" led to issues with competing for the port with apache.
}

# access control list for "purge": open to only localhost and other local nodes
acl purge {
    "app";
}

# vcl_recv is called whenever a request is received 
sub vcl_recv {
        # Serve objects up to 2 minutes past their expiry if the backend
        # is slow to respond.
        # set req.grace = 120s;^[\s;]*
        # This uses the ACL action called "purge". Basically if a request to
        # PURGE the cache comes from anywhere other than localhost, ignore it.
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + server.ip;
        set req.backend_hint = default;

        if (req.method == "PURGE") {
            if (!client.ip ~ purge) {
                return (synth(405, "Not allowed."));
            } else {
                return (purge);
            }
        }

        unset req.http.x-subdomain; # Requester shouldn't be allowed to supply arbitrary X-Subdomain header
        if(req.http.User-Agent ~ "(?i)\b(Android|iPhone\sOS|Nintendo\sSwitch)\b") {
          set req.http.x-subdomain = "m";
        }

        if (req.http.Cookie ~ "mf_useformat=") {
          # This means user clicked on Toggle link "Mobile view" in the footer.
          # Inform vcl_hash() that this should be cached as mobile page.
          set req.http.x-subdomain = "m";
        }

        if (req.method != "GET" && req.method != "HEAD") {
          /* We only deal with GET and HEAD by default */
              return (pass);
        }

        if (req.url ~ "api.php" || req.url ~ "rest.php") {
          return (pass);
        }

        # Pass requests from logged-in users directly.
        # Only detect cookies with "session" and "Token" in file name, otherwise nothing get cached.
        if (req.http.Authorization || req.http.Cookie ~ "([sS]ession|Token)=") {
            return (pass);


        
        } /* Not cacheable by default */

        set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_[_\d\w]*)=[^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)mwuser-sessionId=[^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "^[\s;]*", "");   

 



 
        # # normalize Accept-Encoding to reduce vary
        if (req.http.Accept-Encoding) {
          if (req.http.Accept-Encoding ~ "br") {
            set req.http.Accept-Encoding = "br";
          } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
          } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
          } else {
            unset req.http.Accept-Encoding;
          }
        }
        if (req.url ~ "^(\/load.php|\/resources|\/skins/Vector/resources|\/skins/Vector/resources|\/skins/MinervaNeue/resources)") {
          unset req.http.Cookie;
        }
    
 
        return (hash);
}

sub vcl_pipe {
        # Note that only the first request to the backend will have
        # X-Forwarded-For set.  If you use X-Forwarded-For and want to
        # have it set for all requests, make sure to have:
        # set req.http.connection = "close";
 
        # This is otherwise not necessary if you do not do any request rewriting.
 
        set req.http.connection = "close";
}

# Called if the cache has a copy of the page.
sub vcl_hit {
        if (obj.ttl <= 0s) {
            return (pass);
        }
}

# Called after a document has been successfully retrieved from the backend.
sub vcl_backend_response {
        # Don't cache 50x responses
        if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
            set beresp.uncacheable = true;
            return (deliver);
        }   
 
        if (!beresp.ttl > 0s) {
          set beresp.uncacheable = true;
          return (deliver);
        }
 
        if (beresp.http.Set-Cookie) {
          set beresp.uncacheable = true;
          return (deliver);
        }
 
        if (beresp.http.Authorization && !beresp.http.Cache-Control ~ "public") {
          set beresp.uncacheable = true;
          return (deliver);
        }

        return (deliver);
}


sub vcl_deliver {
      unset resp.http.Via;
      unset resp.http.X-Varnish;
      if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
      } else {
        set resp.http.X-Cache = "MISS";
      }
}

sub vcl_hash {
	# Cache the mobile version of pages separately.
	#
	# NOTE: x-subdomain header should only have one value (if it exists), therefore vcl_recv() should remove user-supplied X-Subdomain header.
	hash_data(req.http.x-subdomain);
}