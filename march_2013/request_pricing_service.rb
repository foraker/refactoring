require './state_pricing/illinois'
require './state_pricing/texaz'

class RequestPricingService
  IN_LABOR_FEE = 20.00
  IN_FIRST_10 = IN_LABOR_FEE
  IN_FIRST_50 = IN_FIRST_10 + 0.64 * 50
  CA_TIME_CHARGE = 4.00
  NC_FIRST_25 = 0.75 * 25
  NC_FIRST_100 = NC_FIRST_25 + 0.50 * 75
  NC_MIN_CHARGE = 10.00

  def self.price(request, number_of_pages = nil)
    return 0.00 unless number_of_pages

    new_states = {
     :tx => StatePricing::Texaz,
     :il => StatePricing::Illinois
    }

    if pricer = new_states[request.state.downcase.to_sym]
      return pricer.price(request, number_of_pages)
    end


    begin
      return RequestPricingService.send("pages_price_#{request.state}", request, number_of_pages)
    rescue NoMethodError
      pages_price_NOSTATUTE(request, number_of_pages)
    end
  end

  #In addition, actual cost of mailing or shipping
  #  Also, a reasonable fee not to exceed $15.00 for executing affidavit.

  def self.pages_price_IN(request, number_of_pages)
    return (IN_FIRST_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50 #>50
    return (IN_FIRST_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10 # 11-50
    return IN_LABOR_FEE
  end

  def self.pages_price_NC(request, number_of_pages)
    return (NC_FIRST_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
    return (NC_FIRST_25 + (number_of_pages - 25) * 0.50) if number_of_pages > 25
    price = ((number_of_pages) * 0.75)
    return NC_MIN_CHARGE if price < NC_MIN_CHARGE #min charge
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