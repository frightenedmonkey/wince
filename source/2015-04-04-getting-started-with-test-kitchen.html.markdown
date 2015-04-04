---
title: Getting Started With Test Kitchen
date: 2015-04-04
tags: test-kitchen
---

<h2>Test-Kitchen</h2>

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

I will assume some basic test-kitchen knowledge. If you haven't read through the
initial docs on the test-kitchen site, go do so now, as it addresses __most__ of
the basics.

<h4>Using Chef Zero for Provisioning</h4>

By default, test-kitchen uses chef-solo to provision the underlying VM. If you
want to apply a more complex workflow with your cookbooks, like with environments
files or data_bags, you will need to switch to using the chef-zero provisioner.

Switching is actually pretty simple, you simply need to designate the provisioner
in your .kitchen.yml file. In that file, you'll have a provisioner block that needs
to be set to look like:

```yaml
provisioner:
  name: chef_zero
```

<h4>DataBags, Environments, and Nodes</h4>

When using 
