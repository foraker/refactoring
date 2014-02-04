class StateBase
  def price(request, number_of_pages)
    self.request = request
    self.number_of_pages = number_of_pages

    calcular_price
  end

  private

  def calcular_price
    raise NoMemoryError
  end

  attr_accessor :request, :number_of_pages
end

class ThresholdPricer
  def parameterize(params)
    @request = params[:request]
    @num_pages = params[:num_pages]
  end
end