Dir["#{File.expand_path('../pricer', __FILE__)}/*"].each { |f| require f }


class PricerFactory

  def self.factory(state_abbr)
    Pricer.const_get :"#{state_abbr}" rescue Pricer::Default
  end

end