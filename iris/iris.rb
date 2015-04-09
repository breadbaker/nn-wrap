require '../nn.rb'
# 5.1,3.5,1.4,0.2,Iris-setosa
class Iris < NN
  def initialize
    @fann_network = false
    @splitter ||= ','
    @file_path ||= './iris.data.txt'
    @epochs ||= 10000
    @pre_scramble = true
    @mse = 0.0001
    @neuron_setup ||= [7]
    @results_path ||= './results'
    super
  end

  def normalize_descrete(data_group, index)
    uniq = data_group.uniq
    puts "uniq #{uniq}"
    normalized = data_group.map do |el|
      options = Array.new(uniq.length, 0)
      options[uniq.index(el)] = 1

      options
    end
    puts normalized[0].length
    normalized
  end
end

a = Iris.new
a.run