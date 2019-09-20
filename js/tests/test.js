var assert, cli, should;

assert = require('chai').assert;

should = require('chai').should();

cli = require('../index');

// Main import
describe('index', function() {
  return it('Returns function', function() {
    return cli.should.be.a('function');
  });
});

//::: End Program :::
