process.env.NODE_ENV = 'test'
process.env.DEBUG = on
process.env.BASE_DOMAIN = "localhost:8000"
global.DEBUG = true
require 'colors'
global.CONFIG = require '../../app/helpers/config'

require '../../app/helpers/languageExtensions'
require '../../app/globals'
require './_addLibsHelper'
matchers = require './matchersHelper'

exportAll = (obj) ->
  global[key] = value for key,value of obj

exportAll require './waitHelper'
exportAll require './testFiddlers'
exportAll matchers

global.exportAll = exportAll
exports.exportAll = exportAll
global.print = console.log
exportAll require './generatorHelper'

Postman = require '../../app/models/postman'
Postman.dryrun = on
AmazonFileUploader = require '../../app/helpers/amazonFileUploader'
AmazonFileUploader.dryrun = on
Q = require 'q'
Q.longStackSupport = on
global.captureAttribute = (attr) -> (valueOrPromise) -> Q(valueOrPromise).then (v) -> v[attr]
global.runFn = (fn) -> (valueOrPromise) -> Q(valueOrPromise).then (v) -> fn v
