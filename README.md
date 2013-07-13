xcode-cli-install
=================

A script to install (&amp; remove) xcode462_cltools for Lion &amp; mountain Lion
Inspired by a [blog post](http://blog.smalleycreative.com/administration/automating-osx-part-one/)

I stored both xcode version in DropBox - so I hope I won't be forced to remove them, the reason they are there is that
you cannot download without an Apple userid and pass which takes the juice out of automating a laptop boot strapping.

If you just want the dmg's click on [Lion](https://www.dropbox.com/s/fnqgdilm0yddfc0/xcode462_cltools_10_76938260a.dmg) or [Mountain Lion](https://www.dropbox.com/s/hw45wvjxrkrl59x/xcode462_cltools_10_86938259a.dmg)

## Usage [ when used standalone ]
	curl -L https://raw.github.com/hagzag/xcode-cli-install/master/install.sh | bash

## Uninstalling [ when used standalone ]
	curl -L https://raw.github.com/hagzag/xcode-cli-install/master/uninstall.sh | bash

**This is 1 of a series of tools/utils to automate your macosx workstation setup**

At some stage I would do this with [Chef](http://www.opscode.com/chef/), but there is a chicken & egg situation and on a new mac the cookbooks for dmg's where quite buggie.

Bugs / Issues are welcome [here](https://github.com/hagzag/xcode-cli-install/issues)

## License 
(The MIT License)

Copyright &copy; 2013 Haggai Philip Zagury. See [LICENSE][:lic] file for more details.

Enjoy
HP