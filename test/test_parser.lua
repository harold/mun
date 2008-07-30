package.path = package.path .. ";../?.lua"
require 'test/lunity'
module( 'TEST_PARSER', lunity )

function setup()
	require 'support/parser'
end

function teardown()
	package.loaded.parser = nil
end

function test01_syntactic_correctness( )
	assertErrors( parser.parseToAST, "foo" )
	assertDoesNotError( parser.parseToAST, "[foo]" )
	assertDoesNotError( parser.parseToAST, "[foo ]" )
	assertDoesNotError( parser.parseToAST, "[ foo]" )
	assertDoesNotError( parser.parseToAST, "[ foo ]" )
	assertDoesNotError( parser.parseToAST, "  [foo]" )
	assertDoesNotError( parser.parseToAST, "\n\n[foo]\t \n \t\n[bar]\n\n" )
	assertDoesNotError( parser.parseToAST, "\n[foo] " )
end

function test02_ast_results( )
	local ast = parser.parseToAST( "[+ 40 2]" )
	assertTableEquals(
		ast, 
		{ -- main program
			type="program",
			{
				type="expression",
				{
					type="symbol",
					value="+"
				},
				{
					type="number",
					value=40
				},
				{
					type="number",
					value=2
				}
			}
		}
	)
end

function test03_codeFromAST( )
	local theCode = "[foo bar]"
	local theProgram = parser.parse( theCode )
	assertTableEquals( theProgram, {
	  head = {
	    head = {
	      symbol = "foo"
	    },
	    tail = {
	      head = {
	        symbol = "bar"
	      },
	    }
	  },
	} )

	local theCode = "[foo 'bar 17 \"whee\"]"
	local theProgram = parser.parse( theCode )
	assertTableEquals( theProgram, {
	  head = {
	    head = {
	      symbol = "foo"
	    },
	    tail = {
	      head = {
	        symbol = "bar",
	        quotedFlag = true
	      },
	      tail = {
	      	head = 17,
	      	tail = {
	      		head = "whee"
	      	}
	      }
	    }
	  },
	} )

	local theCode = "[foo [bar]] [jim]"
	local theProgram = parser.parse( theCode )
	assertTableEquals( theProgram, {
	  head = {
	    head = {
	      symbol = "foo"
	    },
	    tail = {
	    	head = {
	    		head = {
	    			symbol = "bar"
	    		}
	    	}
	    }
	  },
	  tail = {
	  	head = {
	  		head = {
		  		symbol = "jim"  			
	  		}
	  	}
	  }
	} )
	
	local theCode = [===[
		[define map inFunc inList
			[pair [inFunc [head inList]]
				[map 'inFunc [rest inList]]
			]
		]
		[define square x 
			[* x x]
		]
		[print [map square '[1 2 3 4 5]]]
	]===]
	
	local theProgram = parser.parse( theCode )	
	-- assertTableEquals( theProgram, {
	-- 	head={}
	-- 	rest={}
	-- })
end

runTests{ useHTML = true }
