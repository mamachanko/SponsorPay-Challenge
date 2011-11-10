#!/usr/bin/ruby

ENV['RACK_ENV'] = 'test'
require 'rubygems'
require 'minitest/autorun'
require 'rack/test'

begin
	require_relative './sponsorpay.rb'
rescue NameError 
	require File.expand_path('sponsorpay.rb', File.dirname(__FILE__))
end

class MyTest < MiniTest::Unit::TestCase
	include Rack::Test::Methods
	
	def app() Sinatra::Application end

	def test_SponsorPay_get
		get '/'
		assert last_response.ok?
	end
	
	def test_SponsorPay_post
		post '/'
		assert last_response.ok?
	end
end

