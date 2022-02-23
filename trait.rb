class Trait
  def initialize(number, dice, atrib_names)
    @attributes  = {} #Hash.new{|h,k| h[k] = h.dup.clear}
    @num_of_dice = number
    @die_size    = dice
    atrib_names.each do |name|
      if(name.kind_of?(Array))
        @attributes[name.first] = name.last
      else
        @attributes[name] = 0
      end
    end
  end
  
  def edit_attribute
    puts "select which value?"
    @attributes.each{|atb, value| puts "#{atb}" }
    atb = gets.chomp
    puts "current atribute value is #{@attributes[atb]}, replace with what value?"
    value = gets.chomp.to_i
    @attributes[atb] = value
  end
  
  def upgrade_num_of_dice(value)
    @num_of_dice = value
  end
  
  def upgrade_num_die_size(value)
    @die_size = value
  end
  attr_reader :attributes, :num_of_dice, :die_size
end
