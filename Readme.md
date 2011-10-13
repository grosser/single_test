Runs a single test/spec via rake.

INSTALLATION
=====
###As Rails plugin

    script/plugin install git://github.com/grosser/single_test.git

###As Gem

    sudo gem install single_test

Include in your Rakefile:

    require 'single_test'
    SingleTest.load_tasks

USAGE
=====

###Single test/spec
Searches for test-files matching the given name.

    rake spec:user          #run spec/model/user_spec.rb
    rake test:users_c       #run test/functional/users_controller_test.rb
    rake spec:admin/users_c #run spec/controllers/admin/users_controller_spec.rb
    rake test:u*hel         #run test/helpers/user_helper_test.rb

Searches for test-files by class (Foo::Bar -> foo/bar)

    rake spec:Foo::Bar #run spec/foo/bar_spec.rb

###Single test-case/example
    rake spec:user:token    #run the first spec in user_spec.rb that matches /token/
    rake test:user:token    #run all tests in user_test.rb that match /token/

###Spec-server
    rake spec:user X=       #run test on spec_sever (if one is running...), very fast for quick failure pin-pointing

###All one by one
    rake spec:one_by_one    #run each spec/test one by one, to find tests that fail when ran
    rake test:one_by_one    #on their own or produce strange output

###For last mofified file
    rake test:last
    rake spec:last

TIPS
====
 - if `script/spec` is missing, if will use just `spec` for specs (which solves some issues)
 - run whole describe blocks: `describe 'xxx' do describe 'yyy'` --> `rake spec:file:'xxx yyy'`
 - run single examples or describe blocks via line-numbers `rspec spec/foo_spec:123`

TODO
====
 - make test:last more clever e.g. lib -> try spec + spec/lib

Authors
=======

### [Contributors](http://github.com/grosser/single_test/contributors)
 - [Ian Young](https://github.com/iangreenleaf)
 - [Lorrin Nelson](https://github.com/lorrin)
 - [Jason King](https://github.com/smathy)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
