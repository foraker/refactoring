class RequestPricingService
  class State
    attr_reader :number_of_pages

    def initialize(number_of_pages)
      @number_of_pages = number_of_pages
    end
  end

  class Illinois < State
    HANDLING_CHARGE = 25.55
    FIRST_25 = HANDLING_CHARGE + 0.96 * 25
    FIRST_50 = FIRST_25 + 0.64 * 50

    def price
      return HANDLING_CHARGE if number_of_pages < 1
      return (FIRST_50 + (number_of_pages - 50) * 0.32) if number_of_pages > 50
      return (FIRST_25 + (number_of_pages - 25) * 0.64) if number_of_pages > 25
      return (HANDLING_CHARGE + (number_of_pages) * 0.96)
    end
  end

  class Texas < State
    MIN_CHARGE = 25.00

    def price
      return MIN_CHARGE if number_of_pages <= 20
      return (MIN_CHARGE + (number_of_pages - 20) * 0.50)
    end
  end

  class Indiana < State
    LABOR_FEE = 20.00
    FIRST_10 = LABOR_FEE
    FIRST_50 = FIRST_10 + 0.64 * 50

    def price
      return (FIRST_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50 #>50
      return (FIRST_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10 # 11-50
      return LABOR_FEE
    end
  end

  class NorthCarolina < State
    FIRST_25 = 0.75 * 25
    FIRST_100 = FIRST_25 + 0.50 * 75
    MIN_CHARGE = 10.00

    def price
      return (FIRST_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
      return (FIRST_25 + (number_of_pages - 25) * 0.50) if number_of_pages > 25
      price = ((number_of_pages) * 0.75)
      return MIN_CHARGE if price < MIN_CHARGE #min charge
      return price
    end
  end

  class NewJersey < State
    PRICE_PER_PAGE_LOW = 1.00
    SEARCH_FEE = 10.00

    def price
      return 0 if number_of_pages <= 0
      if number_of_pages > 100
        temp = 100 * PRICE_PER_PAGE_LOW + (number_of_pages-100) * 0.25 + SEARCH_FEE
        return temp>200 ? 200.00 : temp.round(2)
      else
        return number_of_pages * PRICE_PER_PAGE_LOW + SEARCH_FEE
      end
    end
  end

  class California < State
    CA_TIME_CHARGE = 4.00

    def price
      0.10 * number_of_pages + CA_TIME_CHARGE
    end
  end

  class NewYork < State
    def price(request)
      if request.requested_by_doctor?
        number_of_pages * 0.75
      else
        if number_of_pages <=15
          return number_of_pages * 2.00
        else
          return 15 * 2.00 + ((number_of_pages - 15) * 1.00)
        end
      end
    end
  end

  class Nevada < State
    def price
      0.60 * number_of_pages
    end
  end

  class Utah < State
    def price
      return 0 if number_of_pages <= 0
      15.00 + number_of_pages * 0.50
    end
  end

  class NoStatute
    attr_reader :number_of_pages

    def initialize(number_of_pages)
      @number_of_pages = number_of_pages
    end

    def price(request)
      if request.requested_by_doctor?
        60.00 + number_of_pages * 1.00
      else
        return 185.00
      end
    end
  end

  def self.price(request, number_of_pages)
    if number_of_pages
      state = request.state.upcase
      case state
        when "IL"
          Illinois.new(number_of_pages).price
        when "TX"
          Texas.new(number_of_pages).price
        when "IN"
          Indiana.new(number_of_pages).price
        when "NC"
          NorthCarolina.new(number_of_pages).price
        when "NJ"
          NewJersey.new(number_of_pages).price
        when "CA"
          California.new(number_of_pages).price
        when "NY"
          NewYork.new(number_of_pages).price(request)
        when "NV"
          Nevada.new(number_of_pages).price
        when "UT"
          Utah.new(number_of_pages).price
        else
          NoStatute.new(number_of_pages).price(request)
      end
    else
      0.00
    end
  end
end