#!/usr/bin/env ruby
# This script gets a in basename defined ttf font and converts them for LaTEX usage
# encoding: utf-8
# @author Sascha Manns
require 'fileutils'  

basename = "Koblenz"

open("#{basename}.map", 'a') { |pdfFontMap|

    Dir["#{basename}*.ttf"].each{ |file|

        file.sub!(/\.ttf$/, "")

        ttf = "#{file}.ttf"

        file.gsub!(/_/,"") # Remove underscores

        puts `ttf2tfm #{ttf} -q -T T1-WGL4.enc -v ec#{file}.vpl rec#{file}.tfm >> ttfonts.map`

        puts `vptovf ec#{file}.vpl ec#{file}.vf rec#{file}.tfm`

        puts `ttf2afm -e T1-WGL4.enc -o rec#{file}.afm #{ttf}`

        pdfFontMap.puts `afm2tfm rec#{file}.afm -T T1-WGL4.enc rec#{file}.tfm`.gsub(/\r|\n/, "") + " <#{ttf}"
    }
}
`mkfontdir && mkfontscale`
