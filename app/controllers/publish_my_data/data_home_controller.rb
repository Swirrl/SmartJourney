module PublishMyData
  class DataHomeController < ApplicationController

    caches_action :index, :docs, :privacy, :accessibility

    def index
      datasets = Dataset.all
      datasets.sort!{|a,b| a.title.downcase <=> b.title.downcase }
      @datasets = Kaminari.paginate_array(datasets).page(1).per(100)
    end
  end
end