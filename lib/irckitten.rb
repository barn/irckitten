#!/usr/bin/env - ruby
#

require 'socket'
require 'resolv'

## These are only used in development.
# require 'rubygems'
# require 'profile'
# require 'awesome_print'
# require 'pry'

# This is to use system_timer if it's there on 1.8.7, or Timeout as a fall
# back. On 1.9.x just use timeout.
# http://davidvollbracht.com/blog/30-days-of-tech-day-1-systemtimer
# http://ph7spot.com/musings/system-timer
if RUBY_VERSION =~ /1\.8\./
  begin
    require 'rubygems'
    require 'system_timer'
    MyTimer = SystemTimer
  rescue LoadError
    require 'timeout'
    MyTimer = Timeout
  end
else
  # 1.9 Timeout works.
  require 'timeout'
  MyTimer = Timeout
end


module IrcKitten

  DNSRECORD = "_irccat._tcp."

  def msg( message )

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

  # Expose these module methods.
  module_function :msg

end
