require '../nn.rb'
# 1000025,5,1,1,1,2,1,3,1,1,2
class Breast < NN
  def initialize
    @fann_network = true
    @match_index = 10
    @splitter ||= ','
    @file_path ||= './breast-cancer-wisconsin.data.txt'
    @epochs ||= 2000
    @neuron_setup ||= [5, 10, 5]
    @results_path ||= './results'
    @special_normalize = {
      10 => :good_or_bad
    }
    super
  end

  def good_or_bad(data_group, index)
    data_group.map do |el|
      if el == 2
        [0,1]
      else
        [1,0]
      end
    end
  end
end

a = Breast.new
a.run