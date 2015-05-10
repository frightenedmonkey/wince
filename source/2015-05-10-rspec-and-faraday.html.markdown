---
title: RSpec and Faraday
date: 2015-05-10
tags: ruby
---

I recently integrated a gem into a project at work that used Faraday for some
internal stuff. The main thing to understand is that I had to prevent any Faraday
errors from bubbling up to the top level project. As such, I attempted to mock out some
of the Faraday methods to return exceptions and ensure they were being handled
correctly. That may not have been the right thing to do in terms of testing, as
it meant I was mucking about in the internals of our external gem dependency.
But it did lead me to discover a recent feature of rspec that I had missed on its
release: [verifying partial doubles](https://relishapp.com/rspec/rspec-mocks/v/3-2/docs/verifying-doubles/partial-doubles).

Verifying doubles ensure that the underlying class actually implements the methods
you are attempting to mock. And attempting to mock the `Faraday.get` method kept
raising rspec errors that the underlying class didn't actually implement the method.

I was completely confused by the errors. I [had totally missed that particular
feature becoming the default in rspec](http://rspec.info/blog/2014/09/rspec-3-1-has-been-released/).

After I finally checked the Faraday source, [it turns out that `GET`, `HEAD`, and
`DELETE` are implemented via `class_eval`](https://github.com/lostisland/faraday/blob/81f16593a0138ec58bb6f25e1c2804e91589662f/lib/faraday/connection.rb#L137-L146)
That makes some sense, given Faraday's architecture (i.e., it's effectively an
HTTP API on top of whatever underlying HTTP library you want to use). But it also
explained why rspec was freaking out since the methods weren't specifically defined
on the class.

There's a bit of an impedance mismatch here that I want to point out. One of the
really neat things about ruby is that you get to do fun metaprogramming type
things when you need to. On the other hand, I can really see the utility of
verifying partials, as you'll want to ensure that your tests are relying on real
methods that have been implemented. You don't want drift to catch you by surprise.

Faraday is using a nifty rubyism that avoids some boilerplate, repetitive code.
And the verifying partials don't really agree with that world. In fact, [rspec
has a page about how to work around the impedance mismatch](https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles/dynamic-classes).

I find the tension I see between these two approaches fascinating. Neither approach
is bad or wrong in any sense. RSpec definitely provides mechanisms to work around
classes that use `method_missing` or other metaprogramming hooks, although for my
use case, I'm not sure that it would have been worth it to go through that level
of extra work. With that said, I greatly appreciate the attempt to provide some
level of an interface guarantee from within my testing toolkit, and I anticipate
exploring that tooling more in the near future.
