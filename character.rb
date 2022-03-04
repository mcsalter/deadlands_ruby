require 'nokogiri'

$LOAD_PATH << '.'
require './trait.rb'


class Character
  def initialize(characterName)
    @character_name = characterName
    @occupation = 'NA'
    
    # trait set up
    @traits = {}
    @traits[:cognition]  = Trait.new(0,0, ['artillery', 'arts', 'scrutinize', ['search', 1],
                                           'trackin', 'blank'])
    @traits[:deftness]   = Trait.new(0,0, ['bow', 'filchin', 'lockpickin', 'shootin','shoot-type',
                                           'sleight o hand', 'speed load', 'throwin', 'throw-type', 'blank'])
    
    @traits[:knowledge]  = Trait.new(0,0, ['academia', 'aca-topic1', 'aca-topic2', 'area knowledge',
                                           'area1', 'demolition', 'disguise', 'language', 'lang-1', 'lang-2',
                                           'mad science', 'medicin', 'med-type', 'professional', 'pro-1', 'pro-2',
                                           'science', 'sci-1', 'sci-2', 'trade', 'trade-1', 'trade-2', 'blank-1',
                                           'blank-2'])
    
    @traits[:mien]       = Trait.new(0,0, ['animal wranglin', 'animal-1', 'leadership', 'overawe',
                                           'performin', 'perf-1', 'persuasion', 'tale tellin', 'blank-1', 'blank-2'])
    
    @traits[:nimbleness] = Trait.new(0,0, [['climbin', 1], 'dodge', 'drivin', 'fightin',
                                           'fight-1', 'fight-2', 'horse ridin', ['sneak', 1], 'swimmin', 'teamster',
                                           'team-1'])
    
    @traits[:quickness]  = Trait.new(0,0, ['quick draw', 'quick-1', 'blank'])
    @traits[:smarts]     = Trait.new(0, 0, %w[bluff gamblin ridicule scroungin streetwise survival surv-1 tinkerin blank-1 blank-2])
    
    @traits[:spirit]     = Trait.new(0, 0, %w[faith guts blank-1 blank-2])
    @traits[:stength]    = Trait.new(0,0, ['blank'])
    @traits[:vigor]      = Trait.new(0,0, ['blank'])
    
    #setting up wound tracking
    @wounds = {:head => 0, :rt_arm => 0, :lt_arm => 0, :guts => 0, :rt_leg => 0, :lt_leg => 0}

    #stats
    @stats = {:pace => 0, :size => 0, :wind => 0, :grit => 0}


    @chips = {:white_chip => 0,:red_chip => 0, :blue_chip => 0}

    #arcane
    @arcane_stats = {:hexslingin => "", :ritual => "", :rituals => ""} 
    @arcane = [{}]
    # list of arcane hashes {:Power => "", :Speed => "", :Duration => "", :Range => "", :Trait => "", :TN => "", :Notes => ""}

    #inventory
    @inventory = {:guns => [{}],
                  :melee => [{:Weapon => "Fist", :Defense => '--', :Speed => 1, :Damage => ""}],
                  :ammo => [0,0,0],
                  :equipment => []}

    # list of gun hashes {:Weapon => "", :Shots => , :RoF => '', :Range => '', :Damage => ""}
    # list of melee weapon hashes{:Weapon => "", :Defense => '', :Speed => , :Damage => ""}

    #character notes
    @notes = {:notes => [], :nightmare => [], :edges => [], :hindrences => []}
  end
  
  def save_character
    #writing the xml file contents:
    @output_file = ''
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Char do
        xml.characterName @character_name
        # traits
        xml.Traits{
          @traits.each do |trait_name, value|
            xml.Trait {
              xml.name trait_name
              xml.num_of_dice value.num_of_dice
              xml.die_size value.die_size
              value.attributes.each do |atb_name, val|
                xml.Attribute { xml.name atb_name; xml.value val }
              end
            }
          end
        }
        # wounds
        xml.Wounds{
          @wounds.each{ |body_location, value| xml.Wound{xml.name body_location; xml.value value}}
        }
        # stats
        xml.Stats{
          @stats.each{ |stat, value| xml.Stat{xml.name stat; xml.value value}}
        }
        # chips
        xml.Chips{
          @chips.each{ |chip, number| xml.Chip{xml.name chip; xml.value number}}
        }
        # arcane
        xml.Arcane do
          xml.Ritual_Info do
            @arcane_stats.each{|header, value|
              xml.Rit{xml.stat header; xml.value value}
            }
          end
          xml.Spell_Info{
            @arcane.each do |power|
              xml.Spell_Block do
                power.each do |name, value|
                  xml.Stat{xml.name name; xml.value value}
                end
              end
            end
          }
        end
        # inventory
        xml.Inventory do
          @inventory.each do |inv_key, value|
            xml.Inv do
              xml.Inv_Type inv_key
              value.each do |inner_value|
                xml.Item do
                  if inner_value.is_a?(Hash)
                    inner_value.each do |inner_inner_key, inner_inner_value|
                      xml.Group do
                        xml.name inner_inner_key
                        xml.value inner_inner_value
                      end
                    end

                  else
                    xml.value inner_value
                  end
                end
              end
            end
          end
        end
        # notes
        xml.Notes do
          @notes.each{ |note_key, value|
            xml.Note do xml.name note_key
              xml.List do
                value.each do |inner_value|
                  xml.contents inner_value
                end
              end
            end
          }
        end
      end
    end
    output_file = builder.doc.to_xml
    # now that the contents are made, write the file itself to ./characters
    file_name = "#{@character_name}.xml"
    file_name.sub!(" ", "-")
    begin
    Dir.chdir("./characters") do
      File.open("#{file_name}", "w+") do |file|
        file.write("#{output_file}")
      end
    end
    rescue
      puts "ERROR: could not enter characters directory, has it been made?"
    end
  end

  def load_character
    begin
      Dir.chdir("./characters") do
        # listing files
        files = Dir.glob("*.xml")
        files.each_with_index{ |file, idx| puts "select the character in #{file} with #{idx}"}
        selection = gets.chomp.to_i
        
        # loading the file portion
        File.open("#{files[selection]}", "r") do |file|
          document = Nokogiri::XML(file)
          @character = document.root
        end
      end
            
    rescue
      puts "ERROR: could not load character"
      return 0
    end
      
    puts "WARNING: clearing character known as #{@character_name}"
    @character_name = @character.at_xpath("characterName").children.text
    
    #recursing through all the traits in the character

    puts "\n--- TRAITS ---" 
    character_trait = @character.at_xpath("Traits")
    trait_list = character_trait.xpath("Trait")
    trait_list.each do |trait|
      trait_name = trait.at_xpath('name').text
      puts "   --- #{trait_name.upcase} ---"
      die_size = trait.at_xpath('die_size').text.to_i
      num_of_dice = trait.at_xpath('num_of_dice').text.to_i
      atb_list = []
      trait.xpath('Attribute').each do |atb|
        puts "       #{atb.at_xpath('name').text}, #{atb.at_xpath('value').text}"
        atb_list << [atb.at_xpath('name').text, atb.at_xpath('value').text.to_i]
      end
      @traits[trait_name.to_sym] = Trait.new(num_of_dice, die_size, atb_list)
    end
    
    puts "\n--- WOUNDS ---"
    character_wounds = @character.at_xpath("Wounds")
    wound_list = character_wounds.xpath("Wound")
    wound_list.each do |wound|
      puts "    #{wound.at_xpath('name').text}, #{wound.at_xpath('value').text}"
      location = wound.at_xpath('name').text
      val = wound.at_xpath('value').text.to_i
      @wounds[location.to_sym] = val
    end

    puts "\n--- STATS ---"
    character_stats = @character.xpath("Stats")
    stat_list = character_stats.xpath("Stat")
    stat_list.each do |stat|
      puts "    #{stat.at_xpath('name').text}, #{stat.at_xpath('value').text}"
      name = stat.at_xpath('name').text
      val = stat.at_xpath('value').text.to_i
      @stats[name.to_sym] = val
    end

    puts "\n--- CHIPS ---"
    character_chips = @character.xpath("Chips")
    chip_list = character_chips.xpath("Chip")
    chip_list.each do |chip|
      puts "    #{chip.at_xpath('name').text}, #{chip.at_xpath('value').text}"
      name = chip.at_xpath('name').text
      val = chip.at_xpath('value').text.to_i
      @chips[name.to_sym] = val
    end

    puts "\n--- ARCANE ---"
    character_arcane = @character.xpath("Arcane")
    puts "   --- ARCANE STATS ---"

    arcane_stats = character_arcane.xpath("Ritual_Info")
    ritual = arcane_stats.xpath("Rit")
    ritual.each do |stat|
      puts "       #{stat.at_xpath('stat').text}, #{stat.at_xpath('value').text}"
      name = stat.at_xpath('stat').text
      val = stat.at_xpath('value').text
      @arcane_stats[name.to_sym] = val
    end

    puts "   --- ARCANE SPELLS ---"
    @arcane = []
    arcane_spells = character_arcane.xpath("Spell_Info")
    spells = arcane_spells.xpath("Spell_Block")
    spells.each do |spell|
      spell_stats = {}
      stats = spell.xpath("Stat")
      stats.each do |stat|
        puts "       #{stat.at_xpath('name').text}, #{stat.at_xpath('value').text}"
        name = stat.at_xpath('name').text
        val = stat.at_xpath('value').text
        spell_stats[name.to_sym] = val
      end
      @arcane.push(spell_stats)
    end


    puts "\n--- INVENTORY ---"
    @inventory = {:guns => [], :melee => [], :ammo => [], :equipment => []}
    character_inventory = @character.xpath("Inventory")
    character_inv_type = character_inventory.xpath("Inv")
    character_inv_type.each do |type|
      type_name = type.at_xpath("Inv_Type").text
      puts "   --- #{type_name.upcase} ---"
      item_list = type.xpath('Item')
      if ['guns','melee'].include?(type_name)
        item_list.each do |item|
          lst = Hash.new
          group = item.xpath("Group")
          group.each do |data|
            name = data.at_xpath('name').text
            value = data.at_xpath('value').text
            puts "       #{name}, #{value}"
            lst[name.to_sym] = value
          end
          @inventory[type_name.to_sym].append(lst)
        end
      elsif ['equipment','ammo'].include?(type_name)
        lst = Array.new
          values = item_list.xpath('value')
          values.each do |value|
            puts "       #{value.text}"
            lst.append(value.text)
          end
          @inventory[type_name.to_sym] = lst
      end
    end

    puts "\n--- NOTES ---"
    character_notes_list = @character.xpath("Notes")
    character_note = character_notes_list.xpath("Note")
    character_note.each do |note|
      list = Array.new
      name = note.at_xpath('name').text.to_sym
      puts "   --- #{name.upcase} ---"
      note_list = note.xpath("List/contents")
      note_list.each do |content|
        puts "       #{content.text}"
        list.append(content.text)
      end
      @notes[name.to_sym] = list
    end

    @character = ''
    return @character_name
  end

  attr_reader :character_name, :traits, :wounds, :stats, :chips, :arcane_stats, :arcane, :inventory, :notes
end
