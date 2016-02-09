require File.expand_path('version', File.dirname(__FILE__))

module Watir
  class Browser
    def initialize(browser=nil, *args)
      self.class.load_driver_for browser

      # execute just loaded driver's #initialize
      initialize browser.nil? && Watir.driver == :webdriver ? :firefox : browser, *args
    end
    
    def try(methodname) #this method is in use in some ruby on rails classes I think. Its the #open? method that I think is the most important though.
      begin
        self.send(methodname.to_sym)
        true
      rescue
        false
	    end
    end

   def open? #response to http://stackoverflow.com/questions/35283059/how-do-i-find-out-if-a-watir-objects-browser-is-closed-or-not-after-typing-ct/35297847#35297847
     if try(:exists?)
	     exists?
	   else
	     false
	   end
  end

    class << self
      def start(url, browser=nil, *args)
        load_driver_for browser

        if Watir.driver == :webdriver
          start url, browser || :firefox, *args
        else
          start url
        end
      end

      def method_missing(name, *args, &block)
        Watir.load_driver
        return super unless respond_to? name
        send name, *args, &block
      end

      def load_driver_for(browser)
        if browser && browser.respond_to?(:to_sym) && browser.to_sym != :ie && Watir.driver == :classic
          Watir.driver = :webdriver 
        end
        Watir.load_driver
      end

    end
  end

  class << self
    def load_driver
      require "watir-#{driver}"
    end

    def driver
      @driver || (ENV["WATIR_DRIVER"] && ENV["WATIR_DRIVER"].to_sym) || default_driver
    end

    def driver=(driver)
      allowed_drivers = %w[webdriver classic]
      unless allowed_drivers.map(&:to_sym).include?(driver.to_sym)
        raise "Supported drivers are #{allowed_drivers.join(", ")}." 
      end
      @driver = driver
    end

    def default_driver
      if ENV['OS'] == 'Windows_NT'
        :classic
      else
        :webdriver
      end
    end
  end
end
