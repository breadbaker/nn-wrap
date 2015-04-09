require '../nn.rb'
# 39, State-gov, 77516, Bachelors, 13, Never-married, Adm-clerical, Not-in-family, White, Male, 2174, 0, 40, United-States, <=50K
class Adult < NN
  def initialize
    @fann_network = true
    @match_index = 13
    @splitter ||= ','
    @file_path ||= './adult.data.txt'
    @epochs ||= 2000
    @neuron_setup ||= [5, 10, 5]
    @results_path ||= './results'
    @test_size = 3000
    @train_size = 6000
    super
  end
end

a = Adult.new
a.run