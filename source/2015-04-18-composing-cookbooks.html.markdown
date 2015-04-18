---
title: Composing Cookbooks
date: 2015-04-18
tags: chef
---
One of the first questions that I had when I started using Chef, after coming from
a background with Puppet, was: are there any best practices or community norms
that provide good guidelines about how cookbooks should be written in order to
facilitate cookbook interaction?

My basic principle here is that a cookbook should only try to do one small thing
well. If a cookbook is the equivalent of a god object, then it's probably doing
it wrong.

#### Integration & Composition

Programming language best practices in the OO world invariably end up quoting the
[Gang of Four Design Patterns book](http://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612/)
(still a book I need to read) that composition should be preferred over inheritance.
I think the same basic principle can be applied to considering how your cookbooks
should interact with each other.

#### An Example of What Not To Do

I recently had the pleasure of poking at a cookbook that was built as a god object.
The cookbook attempted to generically:
<ul>
<li>Creates an app's site local directories
<li>Installs the language required to run the app
<li>Configures and sets up nginx with ssl certs
<li>Configures and sets up passenger (for ruby apps)
</ul>

The functionality for all those things was effectively exposed through resources
defined in the cookbook.

Except:
<ul>
<li>The ssl certs needed for nginx to terminate https requests were not included
<li>There's no way to avoid an app-specific cookbook (if that was the goal)
</ul>


