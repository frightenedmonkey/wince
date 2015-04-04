---
title: Getting Started With Test Kitchen
date: 2015-04-04
tags: test-kitchen
---

<h2>Test-Kitchen</h2>

I use Chef at work, and I've recently embarked on a fair amount of refactoring that
includes breaking some cookbooks out of our monolithic chef repo into individual
ones. As part of that process, I introduced some testing infrastructure to go along
with the new code. In some cases, we only needed to use ChefSpec. In others, test-kitchen
was needed to flesh out the testing story.

While the test-kitchen documentation is good enough to get you started, for some
non-trivial cases, it's not sufficient, and the information needed is buried in
github issues, on the Chef site itself, or just on random blogs (hey!). I wanted
to put together a document that addressed the various use cases that I needed to
handle in my testing.

I will assume some basic test-kitchen knowledge. If you haven't read through the
initial docs on the test-kitchen site, go do so now, as it addresses __most__ of
the basics.

<h4>DataBags</h4>


