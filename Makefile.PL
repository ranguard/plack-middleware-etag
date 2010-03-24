use inc::Module::Install;
name 'Plack-Middleware-ETag';
all_from 'lib/Plack/Middleware/ETag.pm';

requires 'Plack';
requires 'Digest::SHA';
requires 'HTTP::Request::Common';

tests 't/*.t';
author_tests 'xt';

readme_from 'lib/Plack/Middleware/ETag.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
auto_set_repository;
license 'perl';
WriteAll;
