#!/usr/bin/env - ruby
#

require 'socket'
require 'resolv'

## These are only used in development.
# require 'rubygems'
# require 'profile'
# require 'awesome_print'
# require 'pry'

module IrcKitten

  begin
    require 'rubygems'
    require 'system_timer'
    MyTimer = SystemTimer
  rescue LoadError
    require 'timeout'
    MyTimer = Timeout
  end


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

    # I stole this chunk from http://www.das-labor.org/svn/tools/jabber-bot/xmpp4r-0.3/lib/xmpp4r/client.rb
    # Which is GPL, so I think I'm good.
    def self.getsrvrecords
      begin
        srv = []
        Resolv::DNS.open { |dns|
          # If ruby version is too old and SRV is unknown, this will raise a NameError
          # which is catched below
          self.givemedomains.each do |d|
            rr = DNSRECORD + d
            srv = dns.getresources( rr , Resolv::DNS::Resource::IN::SRV)
            break unless srv.nil?
          end
        }
        # Sort SRV records: lowest priority first, highest weight first
        srv.sort! { |a,b| (a.priority != b.priority) ? (a.priority <=> b.priority) : (b.weight <=> a.weight) }

      rescue NameError
        $stderr.puts "Resolv::DNS does not support SRV records. Please upgrade to ruby-1.8.3 or later!"
      end

      srv
    end

  end
end
