use inc::Module::Install;
name 'Plack-Middleware-ETag';
all_from 'lib/Plack/Middleware/ETag.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
