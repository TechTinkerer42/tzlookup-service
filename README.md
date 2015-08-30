# tzlookup service

## Overview

This service leverages the tz_world shapefiles from [efele.net](http://efele.net/maps/tz/world/), to provide a timezone lookup via latitude/longitude. It does so by loading the shapefile into a postgresql database with active postGIS extension.


### Performance vs. Accuracy

Finding the timezones for a given geo coordinate means finding the polygon it resides lies in. The ["Point in polygon"](https://en.wikipedia.org/wiki/Point_in_polygon) problem is generally known to be expensive.

Checking if a coordinate is within the *bounding box* of a polygon is much cheaper, but sacrifices accuracy and introduces situations where points might be within 2 differnt bounding boxes. Accuracy could here be directly traded off in the preprocessing phase by having bigger or smaller bounding boxes.

This service owes it's performance mostly to postgres's postgis extensions speed: The [`ST_Intersects`](http://postgis.org/docs/ST_Intersects.html) method that is being used, uses a fast index based lookup on bounding boxes of the polygons in the database and only runs the accurate/expensive polygon intersection logic on the remaining candidates. This keep the accuracy extremely high with very good performance.

### Scalability of the service

For some examples of the performance this service achieves, see the [benchmark](./benchmark/) folder. The average response time of the service itself  - without network overhead - remains consistently below *10ms* as long as the CPU and connection limits are not at their respective limits.

Since this service does *not* see the postgis enabled database as a shared commodity between all hosts but instead sees it as a purely local datastructure, the service can be infinitely scaled horizontally behind a load balancer without worrying about a central point of failure

## Usage

0. install requirements (vagrant, virtualbox, ansible, ansible-vagrant)

For example on a mac:

	$ brew cask install vagrant virtualbox
	$ brew install ansible
	$ pip install ansible-vagrant

1. spin up virtual machine via vagrant

	$ cd ansible
	$ vagrant up


2. verify the host is up:

	$ curl "http://localhost:8080/time_zone?lat=48.8567&lng=2.348692&api_key=THE_API_KEY"
	OK

3. run tests (depend on running virtual machine!)

    $ bundle install
    $ bundle exec ruby tz_lookups_tests.rb

## Next steps

* ~~tune postgresql (apply https://github.com/gregs1104/pgtune)~~
* tune amount of puma threads/processes
* tune sequel connection pool
* investigate performance impact of api_key validation, should be cached to not add db roundtrip for each call, also requires a centralized way of adding/updating keys
