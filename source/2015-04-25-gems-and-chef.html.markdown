---
title: Gems and Chef
date: 2015-04-25
tags: chef, ruby
---
I found myself needing to ensure a gem was installed during compile time in a
chef run, and which would then become available during convergence. After driving
around the googlemobile for a while, I finally found [Seth Vargo's breakdown](https://sethvargo.com/using-gems-with-chef/)
of the issue.

In addition, in Chef 12.1, there are some changes to the way the `chef_gem` resource
operates [^1]. While this came up as something to pay attention to, our infrastructure
is still operating on chef 11.18.

In my particular circumstance, I was dealing with some pure ruby code in the cookbook's
`library/`. They were plain ruby classes that didn't inherit from Chef's resource
or provider classes like an HWRP would. The ruby classes are accessed in chef via
a method monkeypatched into the Chef::Recipe class. I'm not a huge fan of this
pattern, but I didn't design the system, I just have to build with it.

I was attempting to use a gem within one of my pure ruby classes. I was able to
add a recipe to install the `chef_gem` within the monkeypatched `Chef::Recipe`. 
Although that feels a bit awkward, it works. However! It appears that Chef evaluates
the plain ruby code at multiple times, so if my gem isn't in the load path, then
chef will throw an exception.

In Seth Vargo's post, he suggests one solution as moving the `require` statement
to the method that uses the gem. My solution was probably just as smelly, but it
uses the methods available on rubygems to determine whether to `require` a gem.

Given a gem named `fungus`, your `require` statement looks like:

```ruby
require 'fungus' if Gem::Specification.any? { |g| g.name == 'fungus' }
```

I think that solution is just as smelly as `requiring` a gem within a method,
with the advantage that the `if` statement will make it clear that something specific
is actually going on with that gem. With the proper comments about __why__ we have
to check that the gem is available, then I am signalling to the next developer what
terrible things I was thinking about to make that particular bit of code work.

[^1]: The basic gist is that [gems won't necessarily be installed at compile time](https://www.chef.io/blog/2015/02/17/chef-12-1-0-chef_gem-resource-warnings/).  Per Chef, this change in behavior is more in line with what folks are doing with library cookbooks, and only requiring gems in an LWRP or HWRP provider.
