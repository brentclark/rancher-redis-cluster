#!/usr/bin/python
import redis
import random
import string
import optparse

# Some commmands to run to test.
# python redistest.py --host $HOST --port $PORT --password $PASSWORD
# redis-cli -h $HOST -p $PORT -a $PASSWORD info

def main():
    parser = optparse.OptionParser()
    parser.add_option('-u', '--port', help='Port',  default=False)
    parser.add_option('-p', '--password', help='password', default=False)
    parser.add_option('-n', '--host', help='host', default=False)
    parser.add_option('-r', '--range', help='host', default=2500)
    options, _ = parser.parse_args()

    redis_host     = options.host
    redis_port     = options.port
    redis_password = options.password

    for i in xrange(int(options.range)):
	digits = "".join( [random.choice(string.digits) for i in xrange(random.randint(1, 20))] )
	chars = "".join( [random.choice(string.letters) for i in xrange(random.randint(1, 20))] )

	try:
	    r = redis.StrictRedis(host=redis_host, port=redis_port, password=redis_password, decode_responses=True)
	    r.set(chars, digits)
	except Exception as e:
	    print(e)

	print ("Key: {} and Value: {}".format(chars, digits) )

if __name__ == '__main__':
    main()
