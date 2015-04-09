require '../nn.rb'
# 7,5,mar,fri,86.2,26.2,94.3,5.1,8.2,51,6.7,0,0
class Fire < NN
  def initialize
    @fann_network = true
    @match_index = 12
    @splitter ||= ','
    @file_path ||= './forestfires.csv'
    @epochs ||= 1000
    @neuron_setup ||= [6,6]
    @results_path ||= './results'
    @special_normalize = {
      12 => :did_damage
    }
    super
  end

  def did_damage(data_group, index)
    damaged = 0
    not_damaged = 0
    normalized = data_group.map do |el|
      if el.to_f > 0
        damaged += 1
        [0,1]
      else
        not_damaged += 1
        [1,0]
      end
    end
    puts "damaged #{damaged} not damaged #{not_damaged}"
    normalized
  end
end

a = Fire.new
a.run