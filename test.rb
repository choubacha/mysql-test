require 'mysql'
require 'timeout'
require 'securerandom'

# created a db in mysql:
# create schema testing;
# create table testing.test_blocking ( id int, val varchar(255) );

# created connection
my = Mysql.new('localhost', 'root', '', 'testing')

my.query('truncate table test_blocking')
p = my.prepare('insert into test_blocking (id, val) values (?, ?)')

# insert some nonsense
10_000.times { |n| p.execute(n, SecureRandom.uuid) }

# prepare a run-away cross join
p = my.prepare('select * from test_blocking a join test_blocking b')

# try showing another thread working
Thread.new { loop { puts 'hello'; sleep 0.1 } }
p.execute

# this won't timeout via the Timeout box
Timeout.timeout(1) { p.execute }
