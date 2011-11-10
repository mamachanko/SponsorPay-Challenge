import hashlib, time, operator, urllib2, json

sha = hashlib.sha1()

requestring = 'http://api.sponsorpay.com/feed/v1/offers.json?'

d = {   'appid' : '157',
        'device_id' : '2b6f0cc904d137be2e1730235f5664094b831186',
        'ip' : '212.45.111.17',
        'locale' : 'de',
        'page' : '1',
        'ps_time' : '1312211903',
        'pub0' : 'campaign2',
        'timestamp' : str(int(time.time())),
        'uid' : 'player1',
	}

apikey = 'b07a12df7d52e6c118e5d47d3f9e60135b109a1f'

s = '&'.join(map(lambda x: '='.join(x), sorted(d.iteritems(), key=operator.itemgetter(0))))
sha.update(s + '&' + apikey)
s += '&hashkey=%s' % sha.hexdigest()

r = requestring + s

response = urllib2.urlopen(r)
data = json.load(urllib2.urlopen(r))
responsehash = response.headers['X-Sponsorpay-Response-Signature']

body = response.read()

sha.update(str() + body + apikey)
print sha.hexdigest()
print responsehash 
