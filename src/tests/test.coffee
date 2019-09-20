assert = require('chai').assert
should = require('chai').should()
cli = require('../index')

# Main import

describe 'index', ->
	it 'Returns function', ->
		cli.should.be.a('function')

#::: End Program :::