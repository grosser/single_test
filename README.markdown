PROBLEM
=======
 - to run a single test / single spec you need to know test/spec commandline interface
 - remembering where a file is / typing the full path
 - remember to set the correct options (color/...)

SOLUTION
========
 - simple regex based, rake-ish interface

INSTALL
=======
`script/plugin install git://github.com/grosser/single_test.git`

USAGE
=====

    rake spec:user          #run spec/model/user_spec.rb (search for user*_spec.rb)
    rake test:users_c       #run test/functional/users_controllser_test.rb
    rake spec:admin/users_c #run spec/controllers/admin/users_controller_spec.rb

    rake spec:user:token    #run the first spec in user_spec.rb that matches /token/

    rake spec:user X=       #run test on spec_sever (if one is running...)

AUTHOR
======
Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  