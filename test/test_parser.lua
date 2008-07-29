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
end

function test02_ast_results( )
	local ast = parser.parseToAST( "[+ 40 2]" )
	assertTableEquals(
		ast, 
		{ -- main program
			{
				type="list",
				quoted=false,
				{
					type="symbol",
					quoted=false,
					value="+"
				},
				{
					type="number",
					quoted=false,
					value="40"
				},
				{
					type="number",
					quoted=false,
					value="2"
				}
			}
		}
	)
end

runTests{ useHTML = false }
