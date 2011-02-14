$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'rubygems'
require 'treetop'
require 'parser/crayon'
require 'generator/as3_generator'
require 'snippets'

module Crayon

  describe Generator::AS3Generator do
    def generate(code)
      @parser.parse(code).statements.first.codegen(@generator, true)
    end

    before(:all) do
      @parser = Parser::CrayonParser.new
      @generator = Generator::AS3Generator.new("generator_spec")
    end

    it "should generate basic function calls" do
      generate(SIMPLE_FUNC_CALL).should == "print({__default:y});"
    end

    it "should generate variable assignments" do
      generate(VAR_ASSIGN).should == "var x:* = 10;"
    end

    it "should generate list assignments" do
      generate(ARRAY_ASSIGN).should == "var a:* = [1,2,3,4,5,6,7];"
    end

    it "should generate basic if statements" do
      generate(IF).should == "if(x < 10)\n{\n\n}"
    end

    it "should generate if else statements" do
      generate(IF_ELSE).should == "if(x >= y)\n{\n  print({__default:y});\n}\nelse\n{\n  print({__default:x});\n}"
    end

    it "should generate if ... else if statements" do
      generate(IF_ELSE_IF).should == "if(x >= y)\n{\n  print({__default:y});\n}\nelse if(x < y)\n{\n  print({__default:x});\n}"
    end

    it "should generate if ... else if ... else if statements" do
      generate(IF_ELSE_IF_ELSE_IF).should == "if(x > y)\n{\n  print({__default:x});\n}\nelse if(x < y)\n{\n  print({__default:y});\n}\nelse if(x == y)\n{\n  print({__default:0});\n}"
    end

    it "should generate while loops" do
      generate(WHILE_LOOP).should == "while(x < 10)\n{\n\n}"
    end

    it "should generate simple loops" do
      generate(SIMPLE_LOOP).should == "for(var __i:int = 0; __i < 10; __i++)\n{\n\n}"
    end

    it "should generate code to access list items by number" do
      generate(LIST_ITEM_NUMBER).should == "print({__default:list[5]});"
    end

    it "should generate code to access list items by variable" do
      generate(LIST_ITEM_VAR).should == "print({__default:list[i]});"
    end

    it "should generate function calls without default parameters" do
      generate(FUNC_CALL_NO_DEFAULT).should == "draw_circle({center:[50,50]});"
    end

  end
end
