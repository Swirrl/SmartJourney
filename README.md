# SmartJourney

This is the Rails app which powers http://smartjourney.co.uk.

## Prerequisites

- A Sparql 1.1 http endpoint. We recommend JENA/Fuseki. http://jena.apache.org/documentation/serving_data/index.html
- Memcached
- MongoDB

## Getting started

1. edit config/development|production|test.rb to set up the Tripod config (for connection to the SPARQL endpoint).

2. Check everything's OK by running the tests:

    rake test


3. Seed the database with zones:

    rake db:seed


4. Now you can run the app with Webrick, Passenger, Unicorn etc. e.g.

    rails server


## Licence (MIT) and Copyright

Copyright (C) 2013 Swirrl IT Limited

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
