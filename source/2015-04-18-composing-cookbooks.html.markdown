---
title: Composing Cookbooks
date: 2015-04-18
tags: chef
---
One of the first questions that I had when I started using Chef, after coming from
a background with Puppet, was: are there any best practices or community norms
that provide good guidelines about how cookbooks should be written in order to
facilitate cookbook interaction?

The Chef community has really seemed to buy into [the wrapper cookbook pattern](https://www.chef.io/blog/2013/12/03/doing-wrapper-cookbooks-right/).
Part of the impetus is to provide small bits of reusable code that can be easily
modified via attributes, or, in some cases, to codify organizational standards. The
difficulty for me is that most of the wrapper cookbook discussions don't really
provide a good working example. It's hard for me to really get started with a pattern
unless I can connect an abstract pattern to a concrete problem I face in my day-to-day
work.

After having explored it a bit, I think it's fair to say that the wrapper
cookbook pattern reminds me a lot of the preference of composition
over inheritance in the OO world.

#### An Example

Let's look at it from the perspective of a ruby app we'll call Fungus. What do
you need to run Fungus? It's a ruby web app, so we need ruby. It connects to a
database. It's configured to use memcached. Clients need to connect via ssl, so
we need a reverse proxy that terminates SSL (nginx).

What do the web tier nodes for Fungus need from a config management standpoint?
<ul>
<li>Ruby
<li>Site local directories for deployment & config files
<li>Init scripts of some sort (SysV, Upstart, whatever)
<li>Nginx & config files
<li>An external app server configuration, if necessary (e.g., Passenger)
<li>SSL certs
</ul>

If we assume that each of these items is a recipe, then this is actually really
easy to test.

ChefSpec provides a really pleasant mechanism for testing cookbooks that are put
together with small amounts of responsibility. A [ChefSpec](http://sethvargo.github.io/chefspec/)
spec for a theoretical web recipe might look like this:


```ruby
describe 'fungus::web' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it 'installs ruby' do
    expect(chef_run).to include_recipe("fungus::_ruby")
  end
  it 'installs site local directories' do
    expect(chef_run).to include_recipe("fungus::_site_local")
  end
  it 'installs init scripts' do
    expect(chef_run).to include_recipe("fungus::_init")
  end
  it 'installs and configures passenger' do
    expect(chef_run).to include_recipe("fungus::_passenger")
  end
  it 'provides ssl certs' do
    expect(chef_run).to include_recipe("fungus::_ssl_certs")
  end
end
```

To test this initially, we don't even need to test that those other private
recipes--the ones demarcated by a leading underscore--exist, just that
they're included by the `fungus::web` recipe.

If we then proceed to test the private recipes that are included above, then
let's assume we have an organizational ruby cookbook that we just
need to pull into our `fungus::_ruby` cookbook. In order to test the guarantee
that Fungus provides ruby is as simple as writing this spec:

```ruby
describe 'fungus::_ruby' do
  let(:chef_run) do
    ChefSpec::SoloRunner.converge(described_recipe)
  end

  it 'installs ruby' do
    expect(chef_run).to include_recipe("org-ruby::default")
  end
end
```

#### What's the Big Deal?

If you look at all those example specs, they really aren't very exciting. All
we're really testing is that the specified recipes delegate to other recipes. But
that's actually the point. We've composed the Fungus cookbook out of the reusable
pieces we've hopefully already created.

Even if we don't actually have those reusable pieces yet, we can use this to start
building those, because we're using concrete needs to drive our creation of reusable
components.

Moreover, we don't have to test that the Fungus cookbook does anything more
interesting, because it shouldn't do anything more interesting. An app cookbook
in this world is just pulling together the disparate pieces that do all the hard
work for us. Our tests are simply there to ensure that the proper pieces are all
present.

Attributes in the Fungus cookbook should drive the ruby version, nginx ssl cert
locations, and the app server port to which nginx should be forwarding requests.

#### Pushing Down Implementation Details

If you follow this style, then the responsibility for the implementation details
is going to lay with the lower level wrapper cookbooks. In the examples above,
the Fungus cookbook recipes can all delegate to org-specific cookbooks for ruby,
nginx, etc.

Your specs for any org-specific cookbook will likely be more involved than the
examples above. And you may even need to drill into using
[test-kitchen](http://kitchen.ci/) and writing
[ServerSpec](http://serverspec.org/) code for those cookbooks.

But the broader point here is that responsibility for any one piece is in a cookbook
that has been built specifically for that purpose. You have a ruby cookbook that
you can more easily refactor because it only deals with one thing: ruby.

#### What If We Don't Start From The Outside?

I've been trying to describe how to approach from the outside in, much like you
would work when doing good BDD. As an aside, I really love one of
[Sarah Mei's posts on outside-in BDD](http://www.sarahmei.com/blog/2010/05/29/outside-in-bdd/)
as an example of the workflow from the rails/rspec world.

But what happens if you start from the inside, at the base level--the level
of the constituent parts? I think the trap that many programmers may fall into
when confronted with the situation detail above is to provide a generic app
cookbook that can be used by all ruby apps. The very first thought that I, as a
normal developer would have, is to figure out how to make sure the code that I'm
writing is reusable in the future.

So maybe the first thing I do is think about what a rails app needs, instead of
just thinking about what the ruby web app I'm creating an app cookbook for needs.
A rails app needs:
<ul>
<li>Ruby
<li>Site local directories for deployment & config files
<li>Init scripts of some sort (SysV, Upstart, whatever)
<li>Nginx & config files
<li>An external app server configuration, if necessary (e.g., Passenger)
<li>SSL certs, possibly
</ul>

This should all look very familiar. If we are trying to think generically, then
we might decide to create a `rails_web_app` resource that can be reused in an app
cookbook. That resource may handle all the site local directories, ruby, the init
scripts--everything, because we're going to treat all of our rails apps the same
way.

This isn't necessarily a broken approach. It could actually work fine in a static
system, but it smells to me. Suddenly, we have a cookbook that is responsible
for a broad range of concerns that are a concrete problem for an app,
but are solved in a generic way.

It feels very much like inheritance rather than composition, because the app
cookbook is inheriting all the internal functionality of the generic cookbook,
but that functionality is opaque to the engineer because none of the concerns of
the app are surfaced in the app cookbook, they are hidden in the generic cookbook.

My theoretical concerns aside, what are the realistic implications?

Well, what happens if we have a new ruby app that we don't want to use passenger
for? Or, what if some internal benchmarks show that an app performs better with
unicorn that passenger? What if we want to move a rails app to jruby, and we can't
actually use passenger? What if our generic cookbook only allows for one version
of ruby to be used, and we need to upgrade, but we have a legacy app no one has
touched in two years that we can't verify even runs on ruby 1.9.3, let alone 2.x?

The first thing you'll probably want to do is add some configurables in your
`rails_app` resource to allow people to designate which version of ruby, and the
implementation to be used. But you'll need to make sure you go set sensible defaults,
or you also have to update all the apps that use that resource with the new configurables
at the same time. And maybe you need to add a configurable for the app server,
which also means setting backwards-compatible defaults or updating the resource
everywhere it's used.

What if you've always used capistrano to deploy your app to a given set of directories,
but now you have an internal apt repo and you want to deploy to a custom directory
under `/opt/`? If your `rails_app` resource assumed you'd always deploy to a given
directory, then now you have to go update with more configurables on your resource.

#### This is Not an Academic Exercise

Most of the considerations I've been discussing above are real ones that I've run
into in the last couple of months as my co-workers and I attempt to uncruftify our
config management story.

While there may be some slight exaggerations here and there, the basic contours
are true. In my opinion, you need to start from a concrete situation and work
backwards, not try to genericize a concrete situation in anticipation of the future.

Happy Chefing!
