#!/usr/bin/env ruby

module Mcoll
  class Client
    require 'rubygems' if RUBY_VERSION < "1.9"
    require 'mcollective'
    include MCollective::RPC

    def getresults(fact, value, agent, action)
      response = {}
      mc = rpcclient(agent)
      mc.fact_filter(fact, "/#{value}/")
      mc.progress = false
      mc.send(action).each do |resp|
	begin
	  response[resp[:sender]] = resp[:data][:output]
	rescue
	  response[resp[:sender]] = "ERROR: #{resp[:statusmsg]}"
	end
      end
      mc.disconnect
      response
    end
  end
end
