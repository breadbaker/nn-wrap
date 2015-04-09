require '../nn.rb'
# 5.1,3.5,1.4,0.2,Iris-setosa
class MushRoom < NN
  def initialize
    @fann_network = true
    @splitter ||= ','
    @file_path ||= './agaricus-lepiota.data.txt'
    @epochs ||= 3000
    @match_index = 0
    # @pre_scramble = true
    @mse = 0.05
    @errors_between = 100
    @neuron_setup ||= [20,60,20]
    @results_path ||= './results'
    super
  end
end

a = MushRoom.new
a.run