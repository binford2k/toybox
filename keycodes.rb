#! /usr/bin/env ruby

#
# Look up scancodes from a standard PC keyboard
#
# Accepts either a single string, or an array of strings and symbols.
# Called with a block, will call the block once for each character returned.
#
# Returns: array of hex codes
#
def keycodes(input)
  scancodes = {
      'a'		=> '1e',
      'b'		=> '30',
      'c'		=> '2e',
      'd'		=> '20',
      'e'		=> '12',
      'f'		=> '21',
      'g'		=> '22',
      'h'		=> '23',
      'i'		=> '17',
      'j'		=> '24',
      'k'		=> '25',
      'l'		=> '26',
      'm'		=> '32',
      'n'		=> '31',
      'o'		=> '18',
      'p'		=> '19',
      'q'		=> '10',
      'r'		=> '13',
      's'		=> '1f',
      't'		=> '14',
      'u'		=> '16',
      'v'		=> '2f',
      'w'		=> '11',
      'x'		=> '2d',
      'y'		=> '15',
      'z'		=> '2c',
      '0'		=> '0b',
      '1'		=> '02',
      '2'		=> '03',
      '3'		=> '04',
      '4'		=> '05',
      '5'		=> '06',
      '6'		=> '07',
      '7'		=> '08',
      '8'		=> '09',
      '9'		=> '0a',
      ' '		=> '39',
      '-'		=> '0c',
      '='		=> '0d',
      '['		=> '1a',
      ']'		=> '1b',
      ';'		=> '27',
      '\''	=> '28',
      ','		=> '33',
      '.'		=> '34',
      '/'		=> '35',
      '\t'	=> '0f',
      '\n'	=> '1c',
      '`'		=> '29'
  }

  shiftedScancodes = {
      'A'		=> '1e',
      'B'		=> '30',
      'C'		=> '2e',
      'D'		=> '20',
      'E'		=> '12',
      'F'		=> '21',
      'G'		=> '22',
      'H'		=> '23',
      'I'		=> '17',
      'J'		=> '24',
      'K'		=> '25',
      'L'		=> '26',
      'M'		=> '32',
      'N'		=> '31',
      'O'		=> '18',
      'P'		=> '19',
      'Q'		=> '10',
      'R'		=> '13',
      'S'		=> '1f',
      'T'		=> '14',
      'U'		=> '16',
      'V'		=> '2f',
      'W'		=> '11',
      'X'		=> '2d',
      'Y'		=> '15',
      'Z'		=> '2c',
      ')'		=> '0b',
      '!'		=> '02',
      '@'		=> '03',
      '#'		=> '04',
      '$'		=> '05',
      '%'		=> '06',
      '^'		=> '07',
      '&'		=> '08',
      '*'		=> '09',
      '('		=> '0a',
      '_'		=> '0c',
      '+'		=> '0d',
      '{'		=> '1a',
      '}'		=> '1b',
      ':'		=> '27',
      '|'		=> '28',
      '<'		=> '33',
      '>'		=> '34',
      '?'		=> '35',
      '~'		=> '29'
  }
  
  extScancodes = {
      :esc 		=> ['01'],
      :bksp		=> ['e'],
      :space	=> ['39'],
      :tab	  => ['0f'],
      :caps		=> ['3a'],
      :enter	=> ['1c'],
      :lshift	=> ['2a'],
      :rshift	=> ['36'],
      :ins	  => ['e0', '52'],
      :del	  => ['e0', '53'],
      :end	  => ['e0', '4f'],
      :home		=> ['e0', '47'],
      :pgup		=> ['e0', '49'],
      :pgdown => ['e0', '51'],
      :lgui		=> ['e0', '5b'], # GUI, aka Win, aka Apple key
      :rgui		=> ['e0', '5c'],
      :lctr		=> ['1d'],
      :rctr		=> ['e0', '1d'],
      :lalt		=> ['38'],
      :ralt		=> ['e0', '38'],
      :apps		=> ['e0', '5d'],
      :f1		  => ['3b'],
      :f2		  => ['3c'],
      :f3		  => ['3d'],
      :f4		  => ['3e'],
      :f5		  => ['3f'],
      :f6		  => ['40'],
      :f7		  => ['41'],
      :f8		  => ['42'],
      :f9		  => ['43'],
      :f10	  => ['44' ],
      :f11	  => ['57'],
      :f12	  => ['58'],
      :up		  => ['e0', '48'],
      :left		=> ['e0', '4b'],
      :down		=> ['e0', '50'],
      :right	=> ['e0', '4d'],
  }
  
  releaseScancodes = {
      :lshift	=> ['aa'],
      :rshift	=> ['b6'],
  }

  
  output = []

  input.each do |item|
    if extScancodes.has_key?(item)
      output.concat(extScancodes[item])
    else
      item.each_char do |c|        
        if scancodes.has_key?(c)
          output << scancodes[c]
        else
          # assume we need to hit <shift>!
          output.concat(extScancodes[:lshift])
          output << shiftedScancodes[c]
          output.concat(releaseScancodes[:lshift])
        end
      end
    end
  end
  
  if block_given?
    output.each { |i| yield i }
  end
  
  output
end
