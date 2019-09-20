var c, main, p;

c = require('./cliUtils');

p = require('print-tools-js');

//: Driver
main = async function() {
  var error;
  try {
    p.titleBox('Nuxt Mongoose PWA', {
      titleDesc: 'Setup CLI',
      tagLine: 'Edit your secret key, and edit app/package configuration',
      theme: 'success'
    });
    return (await c.chooseAction());
  } catch (error1) {
    error = error1;
    p.error('Fatal error, will exit.');
    return console.log(error);
  }
};

//: Exports
module.exports = main;
