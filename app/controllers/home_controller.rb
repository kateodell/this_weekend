class HomeController < ApplicationController
  def index
  end

  def show
    @zip = params['zip']
    @events_info = EventFinder.get_events_for_zip(params['zip'])
  end
end
