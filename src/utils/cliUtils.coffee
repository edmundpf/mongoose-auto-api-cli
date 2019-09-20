inq = require('inquirer')
p = require('print-tools-js')
resolve = require('path').resolve
editJson = require('edit-json-file')
c = require('mongoose-auto-api.consumer')

#: Get Default Config
try
	defaultConfig = require('../../node_modules/mongoose-auto-api.rest/js/data/defaultConfig.json')
catch error
	try
		defaultConfig = require('../../../mongoose-auto-api.rest/js/data/defaultConfig.json')
	catch error
		p.error('Could not find default app config file.')
		process.exit(1)

#: Get App Config

try
	appConfig = require('../../../../appConfig.json')
	appConfigPath = resolve("#{__dirname}/../../../../appConfig.json")
catch error
	try
		appConfig = require('../../appConfig.json')
		appConfigPath = resolve("#{__dirname}/../../appConfig.json")
	catch error
		p.error('Could not find app config file.')
		process.exit(1)

#: Get Package Config

try
	packageConfig = require('../../../../package.json')
	packageConfigPath = resolve("#{__dirname}/../../../../package.json")
catch error
	try
		packageConfig = require('../../package.json')
		packageConfigPath = resolve("#{__dirname}/../../package.json")
	catch error
		p.error('Could not find app package file.')
		process.exit(1)

#: Variables

apiRunning = false
defPrompted = false
apiPort = appConfig.serverPort
con = new c()

#::: Helper Methods :::

#: Check if number

isNumber = (text) ->
	if text.length == 0 or !isNaN(text)
		return true
	else
		return 'Please enter a valid number.'

#: Check if not empty

notEmpty = (text) ->
	if text.length > 0
		return true
	else
		return 'Please enter a valid string.'

#: Convert to number

getNumber = (text) ->
	return Number(text)

#: Convert comma-separated string to list

getList = (text) ->
	return text.split(',')

#: Convert string to boolean

getBoolean = (text) ->
	if text == 'true'
		return true
	else
		return false

#: Get author name

authorName = (text) ->
	text = text.toString()
	return text.slice(0, text.indexOf('<') - 1)

#: Get author email

authorEmail = (text) ->
	text = text.toString()
	return text.slice(text.indexOf('<') + 1, text.length - 1)

#: Update JSON file

updateJson = (filename, obj, title) ->
	try
		file = editJson(
			filename,
			autosave: true
		)
		for key, val of obj
			file.set(key, val)
		p.success("Saved #{title} changes.", log: false)
		return true
	catch error
		p.error("Could not update #{title}.")
		return false

#: Method start statements

printMethodStart = (message, useDefaults=true) ->
	p.success("#{message}...", log: false)
	if useDefaults
		p.bullet('Hit enter to use current values.', log: false)

#: Print Error

printError = (res, message) ->
	if res.response?
		if res.response.message?
			p.error(res.response.message)
		else if res.response.messages?
			p.error(res.response.messages.join(' '))
		else
			p.error(message)
	else if res.message
		p.error(res.message)
	else
		p.error(message)

#: Yes/No Question

yesNoPrompt = (message) ->
	return await inq.prompt([
		type: 'rawlist'
		name: 'choice'
		message: message
		choices: ['Yes', 'No']
	])

#: Try Again Prompt

tryAgainPrompt = (func) ->
	answer = await yesNoPrompt('Action failed, would you like to try again?')
	if answer.choice == 'Yes'
		return await func()
	else
		return await chooseAction()

#: Exit Prompt

exitPrompt = ->
	answer = await inq.prompt([
		type: 'rawlist'
		name: 'choice'
		message: 'Would you like to do something else or exit?'
		choices: ['Do something else', 'Exit']
	])
	if answer.choice == 'Do something else'
		return await chooseAction()
	else
		return process.exit(0)

#: Input Prompt

inputPrompt = (message, field, obj, defaultVal=null) ->
	return
		type: 'input'
		name: field
		message: "#{message}:"
		default: if !defaultVal? then obj[field] else defaultVal

#: Number Input Prompt

numInputPrompt = (message, field, obj, defaultVal=null) ->
	return
		type: 'input'
		name: field
		message: "#{message}:"
		validate: isNumber
		filter: getNumber
		default: if !defaultVal? then obj[field] else defaultVal

#: App Config Prompt

appConfigPrompt = (message, field, defaultVal=null) ->
	return inputPrompt(
		message,
		field,
		appConfig,
		defaultVal
	)

#: Number App Config Prompt

numAppConfigPrompt = (message, field, defaultVal=null) ->
	return numInputPrompt(
		message,
		field,
		appConfig,
		defaultVal
	)

#: Package Config Prompt

packageConfigPrompt = (message, field, defaultVal=null) ->
	return inputPrompt(
		message,
		field,
		packageConfig,
		defaultVal
	)

#: Number Package Config Prompt

numPackageConfigPrompt = (message, field, defaultVal=null) ->
	return numInputPrompt(
		message,
		field,
		packageConfig,
		defaultVal
	)

#::: Driver Methods :::

#: Change Default Config

changeDefault = () ->
	answer = await yesNoPrompt(
		'Default database, title, or description detected, would you like to update the app config now?'
	)
	defPrompted = true
	if answer.choice == 'Yes'
		return await updateAppConfig()
	else
		p.bullet('Skipping app config update.', log: false)

#: Check if API is running

checkApi = () ->
	if !apiRunning
		answer = await yesNoPrompt(
			'Is the API already running?'
		)
		if answer.choice == 'No'
			p.bullet('Starting API...', log: false)
			require('mongoose-auto-api.rest')
			apiRunning = true
		else
			answer = await inq.prompt([
				type: 'input'
				name: 'port'
				message: "What port is the API running on?"
				validate: isNumber
				filter: getNumber
				default: apiPort
			])
			p.bullet('API is already running, will not start API.', log: false)
			apiPort = answer.port
			apiRunning = true
			con.setPort(apiPort)

#: Choose Action

chooseAction = () ->
	actions = {
		'Set Secret Key': updateSecretKey
		'Configure Rest API and Web App': updateAppConfig
		'Configure App Package': updatePackageConfig
		'Exit': true
	}
	choices = []
	for key of actions
		choices.push(key)
	if (defPrompted == false && (appConfig.siteTitle == defaultConfig.siteTitle or
		appConfig.siteDesc == defaultConfig.siteDesc or
		appConfig.databaseName == defaultConfig.databaseName))
			await changeDefault()
	else
		defPrompted = true
	answer = await inq.prompt([
		type: 'rawlist'
		name: 'choice'
		message: 'What would you like to do?'
		choices: choices
	])
	if answer.choice != 'Exit'
		await actions[answer.choice]()
	else
		process.exit(0)

#: Login

login = () ->
	try
		printMethodStart(
			'Attempting to log in'
			false
		)
		answer = await inq.prompt([
			{
				type: 'input'
				name: 'username'
				message: 'Enter username:'
				validate: notEmpty
			}
			{
				type: 'password'
				name: 'password'
				message: 'Enter password:'
				validate: notEmpty
				mask: true
			}
		])
		res = await con.login(
			username: answer.username
			password: answer.password
		)
		if res.status == 'ok' and res.response.access_token?
			con.setAuthToken(res.response.access_token)
			p.success('Logged in successfully.', log: false)
			return true
		else
			printError(
				res
				'Could not log in.'
			)
			return await tryAgainPrompt(login)
	catch error
		printError(
			error,
			'Could not log in.'
		)
		return await tryAgainPrompt(login)

#: Update Secret Key

updateSecretKey = () ->
	try
		printMethodStart(
			'Updating Secret Key',
			false
		)
		await checkApi()
		loginCheck = await con.setSecretKey()
		if loginCheck.response.message == 'No token provided.'
			loginRes = await login()
			if loginRes != true
				return await tryAgainPrompt(updateSecretKey)
		keyMatch = false
		while !keyMatch
			answer = await inq.prompt([
				{
					type: 'password'
					name: 'key'
					message: 'Enter secret key:'
					validate: notEmpty
					mask: true
				}
				{
					type: 'password'
					name: 'confirmKey'
					message: 'Confirm secret key:'
					validate: notEmpty
					mask: true
				}
			])
			if answer.key == answer.confirmKey
				keyMatch = true
		res = await con.setSecretKey(key: answer.key)
		if res.status == 'ok'
			if res.response.key?
				p.success('Secret key added successfully.', log: false)
				return await exitPrompt()
			else if res.response.nModified? and res.response.nModified == 1
				p.success('Secret key updated successfully.', log: false)
				return await exitPrompt()
			else
				p.warning('Could not set secret key.')
		else
			printError(
				res,
				'Could not set secret key.'
			)
			return await tryAgainPrompt(updateSecretKey)
	catch error
		printError(
			error,
			'Could not set secret key.'
		)
		return await tryAgainPrompt(updateSecretKey)

#: Update App Config

updateAppConfig = () ->
	printMethodStart('Updating Rest API and Web App Config')
	answer = await inq.prompt([
		appConfigPrompt(
			'Enter app title'
			'siteTitle'
		)
		appConfigPrompt(
			'Enter app description'
			'siteDesc'
		)
		appConfigPrompt(
			'Enter database name'
			'databaseName'
		)
		numAppConfigPrompt(
			'Enter Rest API port'
			'serverPort'
		)
		numAppConfigPrompt(
			'Enter Web App port'
			'webPort'
		)
		numAppConfigPrompt(
			'Enter Mongoose Database port'
			'mongoosePort'
		)
		{
			type: 'input'
			name: 'hiddenFields'
			message: 'Enter hidden Web App fields (comma-separated):'
			filter: getList
			default: appConfig.hiddenFields.join(',')
		}
	])
	updated = updateJson(
		appConfigPath,
		answer,
		'app config'
	)
	if updated
		appConfig = {
			...appConfig,
			...answer
		}
		apiPort = answer.serverPort
		p.warning(
			'The app config has changed and the Rest API may not use the correct database or port, please restart the CLI or server to pull these changes.',
			log:false
		)
		return await exitPrompt()
	else
		return await tryAgainPrompt(updateAppConfig)

#: Update Package Config

updatePackageConfig = () ->
	printMethodStart('Updating App Package Config')
	answer = await inq.prompt([
		packageConfigPrompt(
			'Enter package name'
			'name'
		)
		packageConfigPrompt(
			'Enter package version'
			'version'
		)
		packageConfigPrompt(
			'Enter package description'
			'description'
		)
		packageConfigPrompt(
			'Enter package author name'
			'authorName'
			authorName(packageConfig.author)
		)
		packageConfigPrompt(
			'Enter package author email'
			'authorEmail'
			authorEmail(packageConfig.author)
		)
		packageConfigPrompt(
			'Enter package repository url'
			'homepage'
		)
		{
			type: 'list'
			name: 'private'
			message: 'Is this package private or public?'
			choices: [
				{
					name: 'Private'
					value: true
				}
				{
					name: 'Public'
					value: false
				}
			]
		}
	])
	packageUpdate =
		name: answer.name
		version: answer.version
		description: answer.description
		author: "#{answer.authorName} <#{answer.authorEmail}>"
		homepage: answer.homepage
		private: answer.private
		repository:
			type: 'git'
			url: answer.homepage

	updated = updateJson(
		packageConfigPath,
		packageUpdate,
		'package config'
	)
	if updated
		packageConfig = {
			...packageConfig,
			...packageUpdate
		}
		return await exitPrompt()
	else
		return await tryAgainPrompt(updatepackageConfig)

#::: Exports :::

module.exports = {
	chooseAction
}

#::: End Program :::