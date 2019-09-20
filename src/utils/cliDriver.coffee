c = require('./cliUtils')
p = require('print-tools-js')

#: Driver

main = () ->
	try
		p.titleBox(
			'Nuxt Mongoose PWA',
			titleDesc: 'Setup CLI'
			tagLine: 'Edit your secret key, and edit app/package configuration'
			theme: 'success'
		)
		await c.chooseAction()
	catch error
		p.error('Fatal error, will exit.')
		console.log(error)

#: Exports

module.exports = main