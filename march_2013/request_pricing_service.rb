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

  class NorthCarolina
    FIRST_25 = 0.75 * 25
    FIRST_100 = FIRST_25 + 0.50 * 75
    MIN_CHARGE = 10.00
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
        else
          begin
            return RequestPricingService.send("pages_price_#{state}", request, number_of_pages)
          rescue NoMethodError
            puts "None of the states match pricing rules we defined, #{request.state} for request"
            pages_price_NOSTATUTE(request, number_of_pages)
          end
      end
    else
      0.00
    end
  end

  def self.pages_price_NC(request, number_of_pages)
    return (NorthCarolina::FIRST_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
    return (NorthCarolina::FIRST_25 + (number_of_pages - 25) * 0.50) if number_of_pages > 25
    price = ((number_of_pages) * 0.75)
    return NorthCarolina::MIN_CHARGE if price < NorthCarolina::MIN_CHARGE #min charge
    return price
  end

  #ALL Others  - $185 flat fee + $15 transaction fee
  def self.pages_price_NJ(request, number_of_pages)
    return 0 if number_of_pages <= 0
    price_per_page_low = 1.00
    search_fee = 10.00
    if number_of_pages > 100
      temp = 100 * price_per_page_low + (number_of_pages-100) * 0.25 + search_fee
      return temp>200 ? 200.00 : temp.round(2)
    else
      return number_of_pages * price_per_page_low + search_fee
    end
  end

  CA_TIME_CHARGE = 4.00

  # California
  # Ten cents ($.10) per page for documents 8.5x14 inches or less
  # Twenty cents ($.20) per page for document copies from microfilm
  # Actual costs for oversize documents or special processing
  # Reasonable clerical costs to retrieve records; $4.00 per quarter hour or less
  # Actual postage charges

  #Note - initially we will assume it takes 15 minutes of work to process each record
  def self.pages_price_CA(request, number_of_pages)
    0.10 * number_of_pages + CA_TIME_CHARGE
  end

  #Reasonable charge for paper copies shall not exceed $.75 / page plus postage or shipping and sales tax, if applicable.
  #Requested by qualified person for purposes other than facilitate patients' ongoing health care: $2 / page for first 15 pages, then $1 / page, plus postage.
  def self.pages_price_NY(request, number_of_pages)
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

  def self.pages_price_NV(request, number_of_pages)
    0.60 * number_of_pages #No administrative fee or additional service fee of any kind may be charged for furnishing a copy
  end

  #"UT" => "Base free of $15.00, $0.50/page"
  #"NC" => "Base free of $15.00, $0.50/page, max certification fee $9.32"

  def self.pages_price_UT(request, number_of_pages)
    return 0 if number_of_pages <= 0
    15.00 + number_of_pages * 0.50
  end

  #Patients / Plantiff Lawyers - $60 flat fee + $1 / page + $15 transaction fee.
  def self.pages_price_NOSTATUTE(request, number_of_pages)
    if request.requested_by_doctor?
      fee = 60.00 + number_of_pages * 1.00
    else
      return 185.00
    end
  end
end