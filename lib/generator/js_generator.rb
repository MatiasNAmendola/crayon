# Copyright (c) 2010-2011 Sean Voisen.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'generator/ecmascript_generator'

module Crayon
  module Generator
    
    class JSGenerator < ECMAScriptGenerator

      def initialize(program_name)
        super(program_name)
      end

      def generate(statements)
        preamble << constructor(@class_vars.map{|v| v[:initializer]} + statements) << (@class_vars.length > 0 ? "\n\n" : "") <<
          format(@class_vars.map{|v| v[:declaration]}, 3) << (@functions.length > 0 ? "\n\n" : "") << 
          format(@functions, 3, "\n\n") << conclusion
      end

      def function(name, params = [], body = [], closure = false)
        code = format([
                 (closure ? "" : "p.") + "#{name} = function(params)",
                 "{",
                 format(params.map{|name| add_to_scope(name); "var #{name} = params.#{name};"}, 1),
                 format(body, 1),
                 "}"
        ])

        return code if closure

        @functions.push(code)

        ""
      end

      def loop(i, i_start, i_end, inclusive, statements)
        format([
          "for(var #{i} = #{i_start}; #{i} #{inclusive ? '<=' : '<'} #{i_end}; #{i}++)",
          "{",
          format(statements, 1),
          "}"
        ])
      end

      def call(function_name, arglist, terminate)
        # TODO: This won't work for closures
        "this.#{function_name}(#{arglist})" + (terminate ? ";" : "")
      end

      def var(name)
        class_var_exists?(name) ? "this." + map_var(name) : map_var(name)
      end

      def declare_class_var(var, value)
        {:name => var, :declaration => "p.#{var} = null;", :initializer => "this.#{var} = #{value};"}
      end

      def declare_local_var(var, value)
        "var #{var} = #{value};"
      end

      private

        def preamble
          format([
            "(function(window)",
            "{",
            ""
          ])
        end

        def constructor(statements)
          format([
            "#{program_name} = function(canvas)",
            "{",
            "  this.initialize(canvas);",
            format(statements, 1),
            "}",
            "",
            "var p = #{program_name}.prototype = new CrayonProgram();",
            ""
          ], 1)
        end

        def conclusion
          format([
            "",
            "  window.#{program_name} = #{program_name};",
            "",
            "}(window));"
          ])
        end

    end
  end
end
