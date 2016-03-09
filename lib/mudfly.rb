require 'mudfly/configuration'
require 'mudfly/client'

module Mudfly extend Configuration

  # Delegate to Mudfly::Client

  def self.method_missing(symbol, *args)
    if Client.respond_to?(symbol)
      Client.send(symbol, *args)
    else
      super
    end
  end

  # Delegate to Mudfly::Client

  def self.respond_to?(symbol, include_all = false)
    Client.respond_to?(symbol, include_all) || super(symbol, include_all)
  end

end # Mudfly