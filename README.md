                                     _         _       
                                    | |       (_)      
      ___ ___  _ __  _ __   ___  ___| |_ ___   _  ___  
     / __/ _ \| '_ \| '_ \ / _ \/ __| __/ __| | |/ _ \ 
    | (_| (_) | | | | | | |  __| (__| |_\__ \_| | (_) |
     \___\___/|_| |_|_| |_|\___|\___|\__|___(_|_|\___/ 
                                                    

Realtime event processing for [node](http://nodejs.org). [![Build Status](https://secure.travis-ci.org/chalaschek/connects.io.png?branch=master)](http://travis-ci.org/chalaschek/connects.io)

## Overview

connects.io is a lightweight event processing framework that provides node with event stream filtering and aggregation capabilities similar to those found in complex event processing systems.

It is designed for usecases that require something in between distributed stream processing engines such as [Storm](https://github.com/nathanmarz/storm) & [Esper](http://esper.codehaus.org/) and simpler tools such as [statsd](https://github.com/etsy/statsd/) & [eep-js](https://github.com/darach/eep-js).

## Features
- JSON in and out
- Operators that compute on sliding windows of stream
- Filters (mongo-like patterns and complex functions)
- Triggers

## Installation

> Coming soon.

## Usage

> Coming soon.

> Operators
>   filters
>   injectors (storms calls these functions)
>   project
>   aggregators
>     storm supports combinerAggregtor, reducerAggregtor and aggregator
>     storm also allows chaining aggregagators to emit mulitple aggregates over same partition
>     perhaps this can all be simplified by providing default aggregators as well as an aggregote interface
>       also each aggregator could be provided a window type (sliding, tumbling), length/time, and emit frequency
>     groupBy streams?
>   merge
>   join


## Inspiration

connects.io was inspired by the likes of [eep-js](https://github.com/darach/eep-js) & [statsd](https://github.com/etsy/statsd/), as well as their heavier weight relatives such as [Storm](https://github.com/nathanmarz/storm), [Esper](http://esper.codehaus.org/), [HStreaming](http://www.hstreaming.com/), & [StreamBase](http://www.streambase.com/).

## License

(The MIT License)

Copyright (c) 2013 Christian Halaschek-Wiener &lt;chalaschek@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.