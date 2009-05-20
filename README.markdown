PROBLEM
=======
To run a single test / single spec you need to

 - know test/spec commandline interface
 - remember where a file is
 - type the full path
 - set the correct options (color/...)


USAGE
=====
    script/plugin install git://github.com/grosser/single_test.git

###Single test/spec
    rake spec:user          #run spec/model/user_spec.rb (search for user*_spec.rb)
    rake test:users_c       #run test/functional/users_controller_test.rb
    rake spec:admin/users_c #run spec/controllers/admin/users_controller_spec.rb
    rake test:u*hel         #run test/helpers/user_helper_test.rb (seach for u*hel*_test.rb)

###Single test-case/example
    rake spec:user:token    #run the first spec in user_spec.rb that matches /token/
    rake test:user:token    #run all tests in user_test.rb that match /token/

###Spec-server
    rake spec:user X=       #run test on spec_sever (if one is running...), very fast for quick failure pin-pointing

###All one by one
    rake spec:one_by_one    #run each spec/test one by one, to find tests that fail when ran
    rake test:one_by_one    #on their own or produce strange output


AUTHOR
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  