require 'nokogiri'

$LOAD_PATH << '.'
require './trait.rb'


class Character
  def initialize(characterName)
    @character_name = characterName
    @occupation = 'NA'
    
    # trait set up
    @traits = {}
    @traits[:cognition]  = Trait.new(0,0, ['atrillery', 'arts', 'scrutinize', ['search', 1], 'trackin','blank'])
    @traits[:deftness]   = Trait.new(0,0, ['bow', 'filchin', 'lockpickin', 'shootin','shoot-type', 'sleight o hand',
                                           'speed load', 'throwin', 'throw-type', 'blank'])
    
    @traits[:knowledge]  = Trait.new(0,0, ['academia', 'aca-topic1', 'aca-topic2', 'area knowledge', 'area1', 'demolition',
                                           'disguise', 'language', 'lang-1', 'lang-2', 'mad science', 'medicin', 'med-type',
                                           'professional', 'pro-1', 'pro-2', 'science', 'sci-1', 'sci-2', 'trade', 'trade-1',
                                           'trade-2', 'blank-1', 'blank-2'])
    
    @traits[:mien]       = Trait.new(0,0, ['animal wranglin', 'animal-1', 'leadership', 'overawe', 'performin', 'perf-1',
                                           'persuasion', 'tale tellin', 'blank-1', 'blank-2'])
    
    @traits[:nimbleness] = Trait.new(0,0, [['climbin', 1], 'dodge', 'drivin', 'fightin', 'fight-1', 'fight-2', 'horse ridin',
                                           ['sneak', 1], 'swimmin', 'teamster', 'team-1'])
    
    @traits[:quickness]  = Trait.new(0,0, ['quick draw', 'quick-1', 'blank'])
    @traits[:smarts]     = Trait.new(0,0, ['bluff', 'gamblin', 'ridicule', 'scroungin', 'streetwise', 'survival', 'surv-1',
                                           'tinkerin', 'blank-1', 'blank-2'])
    
    @traits[:spirit]     = Trait.new(0,0, ['faith', 'guts', 'blank-1', 'blank-2'])
    @traits[:stength]    = Trait.new(0,0, ['blank'])
    @traits[:vigor]      = Trait.new(0,0, ['blank'])
    
    #setting up wound tracking
    @wounds = {}
    @wounds[:head]   = 0
    @wounds[:rt_arm] = 0
    @wounds[:lt_arm] = 0
    @wounds[:guts]   = 0
    @wounds[:rt_leg] = 0
    @wounds[:lt_leg] = 0

    #stats
    @stats = {}
    @stats[:pace] = 0
    @stats[:size] = 0
    @stats[:wind] = 0
    @stats[:grit] = 0

    @chips = {}
    @chips[:white_chip] = 0
    @chips[:red_chip]   = 0
    @chips[:blue_chip]  = 0

    #arcane
    @arcane_stats = {:hexslingin => "", :ritual => "", :rituals => ""} 
    @arcane = [{}]
    # list of arcane hashes {:Power => "", :Speed => "", :Duration => "", :Range => "", :Trait => "", :TN => "", :Notes => ""}

    #inventory
    @inventory = {}
    @inventory[:guns]      = []
    # list of gun hashes {:Weapon => "" :Shots => , :RoF => , :Range => , :Damage => ""}
    @inventory[:melee]     = [{:Weapon => "Fist", :Defense => '--', :Speed => 1, :Damage => ""}]
    # list of melee weapon hashes{:Weapon => "", :Defense => '', :Speed => , :Damage => ""}
    @inventory[:ammo]      = [0,0,0]
    @inventory[:equipment] = [] # list of equipment

    #character notes
    @notes = {}
    @notes[:notes]      = ''
    @notes[:nightmare]  = ''
    @notes[:edges]      = ''
    @notes[:hindrences] = ''
  end
  
  def save_character
    #writing the xml file contents:
    @output_file = ''
    @builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Char {
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
              xml.name inv_key
              value.each do |inner_value|
                xml.value inner_value
              end
            end
          end
        end
        # notes
        xml.Notes do
          @notes.each{ |note_key, value|
            xml.Note{xml.name note_key; xml.contents value}
          }
        end
      }
    end
    @output_file = @builder.doc.to_xml
    # now that the contents are made, write the file itself to ./characters
    @file_name = "#{@character_name}.xml"
    @file_name.sub!(" ", "-")
    begin
    Dir.chdir("./characters") do
      File.open("#{@file_name}", "w+") do |file|
        file.write("#{@output_file}")
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
      
      puts "WARNING: clearing character known as #{@character_name}"
      @character_name = @character.at_xpath("characterName").children.text
      
      #recursing through all the traits in the character

      puts "\n--- TRAITS ---" 
      character_trait = @character.at_xpath("Traits")
      trait_list = character_trait.xpath("Trait")
      trait_list.each do |trait|
        trait_name = trait.at_xpath('name').text
        die_size = trait.at_xpath('die_size').text.to_i
        num_of_dice = trait.at_xpath('num_of_dice').text.to_i
        atb_list = []
        trait.xpath('Attribute').each do |atb|
        puts "#{atb.at_xpath('name').text}, #{atb.at_xpath('value').text}"
          atb_list << [atb.at_xpath('name').text, atb.at_xpath('value').text.to_i]
        end
        @traits[trait_name.to_sym] = Trait.new(num_of_dice, die_size, atb_list)
      end
      
      puts "\n--- WOUNDS ---"
      character_wounds = @character.at_xpath("Wounds")
      wound_list = character_wounds.xpath("Wound")
      wound_list.each do |wound|
        puts "#{wound.at_xpath('name').text}, #{wound.at_xpath('value').text}"
        location = wound.at_xpath('name').text
        val = wound.at_xpath('value').text.to_i
        @wounds[location.to_sym] = val
      end

      puts "\n--- STATS ---"
      character_stats = @character.xpath("Stats")
      stat_list = character_stats.xpath("Stat")
      stat_list.each do |stat|
        puts "#{stat.at_xpath('name').text}, #{stat.at_xpath('value').text}"
        name = stat.at_xpath('name').text
        val = stat.at_xpath('value').text.to_i
        @stats[name.to_sym] = val
      end

      puts "\n--- CHIPS ---"
      character_chips = @character.xpath("Chips")
      chip_list = character_chips.xpath("Chip")
      chip_list.each do |chip|
        puts "#{chip.at_xpath('name').text}, #{chip.at_xpath('value').text}"
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
        puts "   #{stat.at_xpath('stat').text}, #{stat.at_xpath('value').text}"
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
          puts "   #{stat.at_xpath('name').text}, #{stat.at_xpath('value').text}"
          name = stat.at_xpath('name').text
          val = stat.at_xpath('value').text
          spell_stats[name.to_sym] = val
        end
        @arcane.push(spell_stats)
      end
    rescue
      puts "ERROR: could not load character"
    end
    @character = ''
    return @character_name
  end

  attr_reader :character_name, :traits, :wounds, :stats, :chips, :arcane_stats, :arcane, :inventory, :notes
end