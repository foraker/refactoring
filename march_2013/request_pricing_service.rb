class RequestPricingService
  def self.price(request, number_of_pages)
    Calculator.new(request, number_of_pages).price
  end

  private
  class Calculator < Struct.new(:request, :number_of_pages)
    def price
      return 0.00 unless number_of_pages
      calculator_class.new(self).price
    end

    def state
      request.state.upcase
    end

    def calculator_class
      state_calculators[state] || DefaultCalculator
    end

    def state_calculators
      {
        'IL' => IllinoisCalculator,
        'TX' => TexasCalculator,
        'IN' => IndianaCalculator,
        'NC' => NorthCarolinaCalculator,
        'NJ' => NewJerseyCalculator,
        'CA' => CaliforniaCalculator,
        'NY' => NewYorkCalculator,
        'NV' => NevadaCalculator,
        'UT' => UtahCalculator
      }
    end

    def default_calculator
      DefaultCaulculator.new(self).price
    end
  end

  class BaseCalculator < Struct.new(:calculator_factory)
    def number_of_pages
      calculator_factory.number_of_pages
    end

    def request
      calculator_factory.request
    end
  end

  class IllinoisCalculator < BaseCalculator
    def price
      case
      when number_of_pages < 1  then handling_charge
      when number_of_pages > 50 then price_for_more_than_fifty_pages
      when number_of_pages > 25 then price_for_more_than_twenty_five_pages
      else default_price
      end
    end

    def price_for_more_than_fifty_pages
      first_50 + (number_of_pages - 50) * 0.32
    end

    def price_for_more_than_twenty_five_pages
      first_25 + (number_of_pages - 25) * 0.64
    end

    def default_price
      handling_charge + number_of_pages * 0.96
    end

    def handling_charge
      25.55
    end

    def first_25
      handling_charge + 0.96 * 25
    end

    def first_50
      first_25 + 0.64 * 50
    end
  end

  class TexasCalculator < BaseCalculator
    def price
      number_of_pages <= 20 ? min_charge : default_price
    end

    def default_price
      min_charge + (number_of_pages - 20) * 0.50
    end

    def min_charge
      25.00
    end
  end

  class IndianaCalculator < BaseCalculator
    def price
      case
      when number_of_pages > 50 then price_for_more_than_fifty_pages
      when number_of_pages > 10 then price_for_more_than_ten_pages
      else price_for_first_10
      end
    end

    def price_for_more_than_fifty_pages
      price_for_first_50 + (number_of_pages - 50) * 0.25
    end

    def price_for_more_than_ten_pages
      price_for_first_10 + (number_of_pages - 25) * 0.50
    end

    def labor_fee
      20.00
    end

    def price_for_first_10
      labor_fee
    end

    def price_for_first_50
      price_for_first_10 + 0.64 * 50
    end
  end

  class NorthCarolinaCalculator < BaseCalculator
    def price
      case
      when number_of_pages > 100    then price_for_more_than_one_hundred
      when number_of_pages > 25     then price_for_more_than_twenty_five
      when have_not_met_min_charge? then min_charge
      else price_for_less_than_twenty_five
      end
    end

    def have_not_met_min_charge?
      price_for_less_than_twenty_five < min_charge
    end

    def price_for_more_than_one_hundred
      price_for_first_100 + (number_of_pages - 100) * 0.25
    end

    def price_for_more_than_twenty_five
      price_for_first_25 + (number_of_pages -  25) * 0.50
    end

    def price_for_less_than_twenty_five
      (number_of_pages) * 0.75
    end

    def price_for_first_25
      0.75 * 25
    end

    def price_for_first_100
      price_for_first_25 + 0.50 * 75
    end

    def min_charge
      10.00
    end
  end

  class NewJerseyCalculator < BaseCalculator
    def price
      return 0 if number_of_pages <= 0
      number_of_pages > 100 ? price_for_more_than_100_pages : price_for_100_or_less_pages
    end

    def price_for_more_than_100_pages
      [100 * price_per_page + (number_of_pages-100) * 0.25 + search_fee, max_price].min.round(2)
    end

    def price_for_100_or_less_pages
      number_of_pages * price_per_page + search_fee
    end

    def max_price
      200.00
    end

    def price_per_page
      1.00
    end

    def search_fee
      10.00
    end
  end

  class CaliforniaCalculator < BaseCalculator
    def price
      0.10 * number_of_pages + time_charge
    end

    def time_charge
      4.00
    end
  end

  class NewYorkCalculator < BaseCalculator
    def price
      case
      when request.requested_by_doctor? then number_of_pages * 0.75
      when number_of_pages <= 15        then price_for_15_or_less_pages
      else price_for_more_than_15_pages
      end
    end

    def price_for_15_or_less_pages
      number_of_pages * 2.00
    end

    def price_for_more_than_15_pages
      15 * 2.00 + ((number_of_pages - 15) * 1.00)
    end
  end

  class NevadaCalculator < BaseCalculator
    def price
      price_per_page * number_of_pages
    end

    def price_per_page
      0.60
    end
  end

  class UtahCalculator < BaseCalculator
    def price
      return 0 if number_of_pages <= 0
      base_price + number_of_pages * price_per_page
    end

    def base_price
      15.0
    end

    def price_per_page
      0.5
    end
  end

  class DefaultCalculator < BaseCalculator
    def price
      request.requested_by_doctor? ? price_for_doctor : price_for_everybody_else
    end

    def price_for_doctor
      base_doctor_price + number_of_pages * price_per_page_for_doctors
    end

    def base_doctor_price
      60.0
    end

    def price_per_page_for_doctors
      1.0
    end

    def price_for_everybody_else
      185.0
    end
  end
end
