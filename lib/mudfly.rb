require 'mudfly/configuration'
require 'mudfly/client'

module Mudfly extend Configuration
  
  # Delegate to Mudfly::Client

  def self.method_missing(symbol, *args)

    if Client.respond_to?(symbol)

      return Client.send(symbol, *args)

    else

      return super

    end
    
  end

  # Delegate to Mudfly::Client

  def self.respond_to?(symbol, include_all = false)

    return Client.respond_to?(symbol, include_all) || super(symbol, include_all)

  end

end # Mudfly