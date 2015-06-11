--------------------
Varnish Cache Warmup
--------------------

:Author: Arianna Aondio
:Date: 2015-06-11

DESCRIPTION
===========

Simple script for prewarm Varnish nodes before allowing
traffic to hit them.

The script traverse the access.log file and execute siege
or wget requests.
