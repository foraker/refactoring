require_relative 'states/abbreviations'

class State
  attr_reader :number_of_pages, :request

  def initialize(number_of_pages, request = nil)
    @number_of_pages = number_of_pages
    @request = request
  end
end

class Illinois < State
  HANDLING_CHARGE = 25.55
  FIRST_25 = HANDLING_CHARGE + 0.96 * 25
  FIRST_50 = FIRST_25 + 0.64 * 50

  def price
    case
      when number_of_pages < 1
        HANDLING_CHARGE
      when number_of_pages > 50
        (FIRST_50 + (number_of_pages - 50) * 0.32)
      when number_of_pages > 25
        (FIRST_25 + (number_of_pages - 25) * 0.64)
      else
        (HANDLING_CHARGE + (number_of_pages) * 0.96)
    end
  end
end

class Texas < State
  MIN_CHARGE = 25.00

  def price
    return MIN_CHARGE if number_of_pages <= 20
    (MIN_CHARGE + (number_of_pages - 20) * 0.50)
  end
end

class Indiana < State
  LABOR_FEE = 20.00
  FIRST_10 = LABOR_FEE
  FIRST_50 = FIRST_10 + 0.64 * 50

  def price
    return (FIRST_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50 #>50
    return (FIRST_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10 # 11-50
    LABOR_FEE
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
    price
  end
end

class NewJersey < State
  PRICE_PER_PAGE_LOW = 1.00
  SEARCH_FEE = 10.00

  def price
    return 0 if number_of_pages <= 0
    if number_of_pages > 100
      temp = 100 * PRICE_PER_PAGE_LOW + (number_of_pages-100) * 0.25 + SEARCH_FEE
      temp > 200 ? 200.00 : temp.round(2)
    else
      number_of_pages * PRICE_PER_PAGE_LOW + SEARCH_FEE
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
  def price
    if request.requested_by_doctor?
      number_of_pages * 0.75
    else
      if number_of_pages <=15
        number_of_pages * 2.00
      else
        15 * 2.00 + ((number_of_pages - 15) * 1.00)
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
    if number_of_pages <= 0
      0
    else
      15.00 + number_of_pages * 0.50
    end
  end
end

class NoStatute
  attr_reader :number_of_pages, :request

  def initialize(number_of_pages, request = nil)
    @number_of_pages = number_of_pages
    @request = request
  end

  def price
    if request.requested_by_doctor?
      60.00 + number_of_pages * 1.00
    else
      185.00
    end
  end
end

class RequestPricingService
  def self.price(request, number_of_pages)
    return 0.00 unless number_of_pages

    state_abbr = request.state.upcase
    state_name = States::ABBREVIATIONS_MAPPING[state_abbr].gsub(" ", "")

    begin
      const_get(state_name).new(number_of_pages, request).price
    rescue
      NoStatute.new(number_of_pages, request).price
    end
  end
end
