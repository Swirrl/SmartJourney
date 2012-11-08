module PublishMyData
  class DataHomeController < ApplicationController

    caches_action :index, :docs, :privacy, :accessibility

    def index
      datasets = Dataset.all
      datasets.sort!{|a,b| dataset_order_comparison_operand(a) <=> dataset_order_comparison_operand(b) }
      @datasets = Kaminari.paginate_array(datasets).page(1).per(100)
    end
  end
end