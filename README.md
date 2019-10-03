# Mongoose Auto API - Setup CLI module
[![Build Status](https://travis-ci.org/edmundpf/mongoose-auto-api-cli.svg?branch=master)](https://travis-ci.org/edmundpf/mongoose-auto-api-cli)
[![npm version](https://badge.fury.io/js/mongoose-auto-api.cli.svg)](https://badge.fury.io/js/mongoose-auto-api.cli)
> Automatic Mongoose REST API - Setup CLI Module ☕

## Install
* `npm i -S mongoose-auto-api.cli`

## Model Setup
* [Model Setup - mongoose-auto-api.info](https://github.com/edmundpf/mongoose-auto-api-info/blob/master/README.md#model-setup)

## Usage
``` javascript
cli = require('mongoose-auto-api.cli')
cli()
```

## CLI Options
* *Set Secret Key*
	* Sets secret key, must have a secret key to add admin users to the Rest API and web app.
* *Configure Rest API and Web App*
	* Configures Rest API and Web App settings such as title, description, ports, hidden fields, etc.
* *Configure App Package*
	* Configures fields in app's `package.json` file such as name, description, author, repository, etc.
* *Create SSL Keys*
	* Creates SSL Keys to secure PWA
* *Exit*
	* Closes the CLI
