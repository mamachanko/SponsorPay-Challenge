#! /usr/bin/ruby

### SponsorPay Challenge
#
# Solution by Max Brauer
# Date of submission: 10th of November 2011
# Requirements: Sinatra and Json

#set up the imports
require 'digest/sha1'
require 'net/https'
require 'sinatra'
require 'json'
require 'rubygems'

#make the base url and the apikey globally known
$requeststring = 'http://api.sponsorpay.com/feed/v1/offers.json?'
$apikey = 'b07a12df7d52e6c118e5d47d3f9e60135b109a1f'

def getTimestamp()
	# returns a unix timestamp
	# params: none
	Time.now.to_i
end

def compileRequestString(uid = 'player1', pub0 = 'campaign2', page = '1')
	# compiles the string of paramters and value delimited by '&' and '=' respectively
	# the hashvalue of that string together with the apikey will be appended
	# params: uid = 'player1'
	#	  pub0 = 'campaign2'
	#         page = '1'

	# a hash holding the relevant keys and values		
	params = {	'appid' => '157',
        		'device_id' => '2b6f0cc904d137be2e1730235f5664094b831186',
	        	'ip' => '212.45.111.17',
	        	'locale' => 'de',
		        'page' => page,
		        'pub0' => pub0,
			# compute the timestamp in time
        		'timestamp' => getTimestamp(),
	        	'uid' => uid,
			'offer_types' => '112'}
	# set up an array so the params can be sorted alphatetically
	paramslist = []
	params.each do|k,v|
		paramslist << "#{k}=#{v}"
	end
	# sort alphabetically
	paramslist.sort!
	# join the pieces
	paramstring = paramslist.join('&')
	# append the sha1 value of the whole string concatenated by the apikey
	hashvalue = Digest::SHA1.hexdigest paramstring + '&' + $apikey
	paramstring << '&hashkey=' + hashvalue
	# return the baseurl with the compiled parameter string
	$requeststring + paramstring
end

get '/' do
	# handle the get call to page

	# do this by returning the form(see end of file)
	erb :form
end

post '/' do
	# handle the post call to the page

	# compile the request string
	requeststring = compileRequestString(uid = params[:uid], pub0 = params[:pub0], page = params[:page])
	# show it (for debugging purposes)
	puts 'requesting ' + requeststring
	# perform the actual call to the json api
	req = Net::HTTP.get_response(URI.parse(requeststring))
	# dig up the hash from the http response header
	responsehash = req['X-Sponsorpay-Response-Signature']
	# retrieve the actual data from the response
	# as json
	@data = JSON.parse(req.body)
	# and raw
	@body = req.body
	# compute the hashvalue of the body and the apikey to check intergrity
	hashvalue = Digest::SHA1.hexdigest @body + $apikey
	# check the integrity and keep it's result in @isok
	@isok = false
	if responsehash == hashvalue:
		@isok = true
	end
	# render the results(see erb template at the end of the file)
	erb :result
end

__END__
@@ layout
<html>
	<title>SponsorPay Challange</title
	<body>
		<%= yield %>
	</body>
</html>

@@ result
<h1>Result</h1>
<h2>Trust</h2>
<% if @isok == true %>
	The response is trustworthy.
<% else %>
	The response can't be trusted!
<% end %>
<h2>Offers</h2>
<% if @data.has_key?('offers') %>
	<ul>
	<% @data['offers'].each do |offer| %>
		<li>
		<div class=‘offer’>
			<div class=‘title’>
				<h3><%= offer['title'] %></h3>
			</div>
			<div class=‘payout’>
				Payout: <%= offer['payout'] %>
			</div>
			<div class=‘thumbnail’>
				<% imagesrc = offer['thumbnail']['lowres'] %>
				<%= "<img src='#{imagesrc}'/>" %>
			</div>
		</div>
		</li>
	<% end %>
	</ul>
<% else %>
	<div class=‘no_offers’>
		No offers
	</div>
<% end %>

@@ form
<h1>Form</h1>
<form action="/" method="post">
	uid: <input type="text" name="uid" value="player1"></br>
	pub0: <input type="text" name="pub0" value="campaign1"></br>
	page: <input type="text" name="page" value="1"></br>
	<input type="submit">
</form>
