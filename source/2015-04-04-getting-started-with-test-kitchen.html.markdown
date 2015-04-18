---
title: Nodes & Environments With Test Kitchen
date: 2015-04-04
tags: test-kitchen, chef
---
I use [Chef](https://www.chef.io) at work, and I've recently embarked on a fair
amount of refactoring that includes breaking some cookbooks out of our monolithic
chef repo into individual ones. As part of that process, I introduced some testing
infrastructure to go along with the new code. In some cases, we only needed to
use [ChefSpec](http://sethvargo.github.io/chefspec/). In others,
[test-kitchen](http://kitchen.ci/) was needed to flesh out the testing story.

While the [test-kitchen documentation](http://kitchen.ci/docs/getting-started/)
is good enough to get you started, for some non-trivial cases, it's not sufficient,
and the information needed is buried in github issues, on the Chef site itself,
or just on random blogs (hey!). I wanted to put together a document that addressed
the various use cases that I needed to handle in my testing.

I will assume some basic test-kitchen knowledge. If you haven't read through [the
initial docs on the test-kitchen site](http://kitchen.ci/docs/getting-started/),
go do so now, as it addresses __most__ of the basics.

<h4>Using Chef Zero for Provisioning</h4>

By default, test-kitchen uses chef-solo to provision the underlying VM. If you
want to apply a more complex workflow with your cookbooks, like with environments
files or data_bags, you will need to switch to using the chef-zero provisioner.

Switching is actually pretty simple, you simply need to designate the provisioner
in your `.kitchen.yml` file. In that file, you'll have a provisioner block that needs
to be set to look like:

```yaml
provisioner:
  name: chef_zero
```

<h4>DataBags, Environments, and Nodes</h4>

When using chef-zero as your provisioner, you can also specify directories for
databags, environments, and nodes in your chef environment. The directories don't
need to be in any specific parent directory. I usually place them directly within
the cookbooks top-level test directory. The databag, environments, and nodes
configuration entries belong in the provisioner directive.

The provisioner directive block now looks like:

```yaml
provisioner:
  name: chef_zero
  environments_path: 'test/environments'
  data_bags_path: 'test/data_bags'
  nodes_path: 'test/nodes'
```

<h4>DataBags!</h4>

Databags in test-kitchen look just like databags anywhere else in chef. There's
nothing special to know here.

<h4>Environments!</h4>

You do need to use json files for environments with test-kitchen. I'm not quite
clear why that is, as you don't need to use json files specifically for Chef or chef-zero.
Regardless, if you need a particular environment, you can define one to look like
this:

```json
{
  "name":"staging",
  "json_class":"Chef::Environment",
  "chef_type":"environment"
}
```

<h4>Nodes!</h4>

Nodes are interesting. It seems like something of an antipattern to test your
independent cookbook in an environment that requires the existence of many other
nodes. However, in my particular case, I was stuck with some design that required
the use of chef search to populate some local information. As such, I needed to
have some extra nodes defined to satisfy my tests.

Each node can be defined in a json file that looks like this:

```json
{
  "id": "es-01.foo.com",
  "fqdn": "es-01.foo.com",
  "chef_environment": "staging",
  "run_list": ["role[elasticsearch]"],
  "automatic": {
    "ipaddress": "192.168.88.88"
  }
}
```

For my particular use case, I was searching on roles on a per environment basis,
so this basic setup on a node was sufficient to satisfy my needs. Other attributes
could certainly be set, but I think that even exposing this particular ability is
sketchy.

