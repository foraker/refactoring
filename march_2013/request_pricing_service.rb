class RequestPricingService
  def self.price(request, number_of_pages)
    if number_of_pages
      state = request.state.upcase
      price_handler = if PricingHandlers.const_defined?(state.to_sym)
        PricingHandlers.const_get(state.to_sym).new(request, number_of_pages)
      else
        PricingHandlers::NoState.new(request, number_of_pages)
      end
      price_handler.value
    else
      0.00
    end
  end

  module PricingHandlers
    class BaseHandler
      attr_reader :request, :number_of_pages

      def initialize(request, number_of_pages)
        @request = request
        @number_of_pages = number_of_pages
      end

      def doctor?
        request.requested_by_doctor?
      end
    end

    class IL < BaseHandler
      HANDLING_CHARGE = 25.55
      HANDLING_QUOTIENT = 0.32

      def value
        if number_of_pages < 1
          HANDLING_CHARGE
        elsif number_of_pages > 50
          first_50_handling_charge + (number_of_pages - 50) * HANDLING_QUOTIENT
        elsif number_of_pages > 25
          first_25_handling_charge + (number_of_pages - 25) * (HANDLING_QUOTIENT * 2)
        else
          HANDLING_CHARGE + (number_of_pages) * (HANDLING_QUOTIENT * 3)
        end
      end

      def first_25_handling_charge
        HANDLING_CHARGE + 0.96 * 25
      end

      def first_50_handling_charge
        first_25_handling_charge + 0.64 * 50
      end
    end

    class TX < BaseHandler
      MIN_CHARGE = 25.00

      def value
        if number_of_pages <= 20
          MIN_CHARGE
        else
          MIN_CHARGE + (number_of_pages - 20) * 0.50
        end
      end
    end

    class IN < BaseHandler
      LABOR_FEE = 20.00
      HANDLING_QUOTIENT = 0.25

      def value
        if number_of_pages > 50
          first_50_handling_charge + (number_of_pages - 50) * HANDLING_QUOTIENT
        elsif number_of_pages > 10
          LABOR_FEE + (number_of_pages - 25) * (HANDLING_QUOTIENT * 2)
        else
          LABOR_FEE
        end
      end

      def first_50_handling_charge
        LABOR_FEE + 0.64 * 50
      end
    end

    class NC < BaseHandler
      FIRST_25 = 18.75
      MIN_CHARGE = 10.00
      HANDLING_QUOTIENT = 0.25

      def value
        if number_of_pages > 100
          first_100_handling_charge + (number_of_pages - 100) * HANDLING_QUOTIENT
        elsif number_of_pages > 25
          FIRST_25 + (number_of_pages -  25) * (HANDLING_QUOTIENT * 2)
        else
          [base_price, MIN_CHARGE].max
        end
      end

      def base_price
        (number_of_pages) * 0.75
      end

      def first_100_handling_charge
        FIRST_25 + 37.5
      end
    end

    class NJ < BaseHandler
      PRICE_PER_PAGE_LOW = 1.00
      SEARCH_FEE = 10.00

      def value
        if number_of_pages <= 0
          0
        elsif number_of_pages > 100
          [base_price.round(2), 200].min
        else
          number_of_pages * PRICE_PER_PAGE_LOW + SEARCH_FEE
        end
      end

      def base_price
        100 * PRICE_PER_PAGE_LOW + (number_of_pages - 100) * 0.25 + SEARCH_FEE
      end
    end

    class CA < BaseHandler
      TIME_CHARGE = 4.00
      HANDLING_QUOTIENT = 0.10

      def value
        TIME_CHARGE + number_of_pages * HANDLING_QUOTIENT
      end
    end

    class NV < BaseHandler
      def value
        0.60 * number_of_pages
      end
    end

    class UT < BaseHandler
      HANDLING_QUOTIENT = 0.50
      def value
        if number_of_pages <= 0
          0
        else
          15.00 + number_of_pages * HANDLING_QUOTIENT
        end
      end
    end

    class NY < BaseHandler
      def value
        if doctor?
          number_of_pages * 0.75
        else
          if number_of_pages <= 15
            number_of_pages * 2.00
          else
            15 * 2.00 + ((number_of_pages - 15) * 1.00)
          end
        end
      end
    end

    class NoState < BaseHandler
      def value
        if doctor?
          60.00 + number_of_pages * 1.00
        else
          185.00
        end
      end
    end
  end
end