#!/usr/bin/env - ruby
#

require 'socket'
require 'resolv'

## These are only used in development.
# require 'rubygems'
# require 'profile'
# require 'awesome_print'
# require 'pry'


begin
  require 'rubygems'
  require 'system_timer'
  MyTimer = SystemTimer
rescue LoadError
  require 'timeout'
  MyTimer = Timeout
end

module IrcKitten

  class IrcKitten

    DNSRECORD = "_irccat._tcp."

    def self.msg( message )

      self.getsrvrecords.each do |addy|
        return true \
          if self.sendmessage( message , addy.target.to_s , addy.port )
      end

      false
    end

    private

    def self.givemedomains
      @myhostname ||= Socket.gethostname
      currentdomain = @myhostname

      domain = []
      while currentdomain != nil
        currentdomain = self.dropazone( currentdomain )
        domain << currentdomain
      end
      domain
    end

    # I think this works in a funcitonal programming kinda way.
    # When you run out it should return nil
    def self.dropazone( rr )
      bits = rr.split '.'
      return nil if bits.empty?
      bits[1,bits.size].join('.')
    end

    def self.sendmessage( message , host , port )
      s = nil

      begin
        MyTimer.timeout( 10 ) do
          s = TCPSocket.new host, port
          s.puts message
        end
      rescue Timeout::Error
        $stderr.puts "Timed out talking to #{host}:#{port}"
        return false
      ensure
        s.close unless s.nil?
      end

      true
    end

    # Get the SRV records from DNS, uses the constant to add to each
    # domain to get the record to try. Returns a vaguely sorted thing.
    def self.getsrvrecords

      srvs = nil
      begin
        Resolv::DNS.open do |dns|
          self.givemedomains.each do |domain|
            srvs = dns.getresources( DNSRECORD + domain , Resolv::DNS::Resource::IN::SRV)
            break unless srvs.nil?
          end
        end

        # Don't bother sorting them if we just have one!
        return srvs if srvs.size == 1

        srvs.sort! { |a,b| (a.priority != b.priority) ? (a.priority <=> b.priority) : (b.weight <=> a.weight) }

      rescue NameError => e
        $stderr.puts "Problem resolving DNS due to #{e}."
      end

      srvs
    end

  end
end
