inquirer = require "inquirer"
cowsay = require "cowsay"
path = require "path"
l = console.log
fs = require "fs"
c = require "chalk"
mkdirp = require "mkdirp"
wrench = require "wrench"
mv = (patha, pathb)->
  l c.grey "mv #{patha} #{pathb}"
  fs.renameSync patha, pathb
cpr = (patha,pathb)->
  l c.grey "cp -r "+patha+" "+pathb
  wrench.copyDirSyncRecursive patha, pathb
cp= (patha, pathb)->
  l c.grey "cp "+patha+" "+pathb
  fs.writeFileSync(pathb, fs.readFileSync(patha))
dir = (ppart)->
  path.join __dirname, ppart
sedi = (file, toRep, rep)->
  l c.grey "sed -i '#{toRep}->#{rep}' #{file}"
  data = fs.readFileSync file, "utf8"
  patt = new RegExp toRep, "g"
  result = data.replace(patt, rep)
  fs.writeFileSync file, result, "utf8"
mkdir = (path)->
  l c.grey "mkdir -p "+path
  mkdirp path
lingo = require "lingo"
progress = require "progress"
rimraf = require "rimraf"
rm = (path)->
  l c.grey "rm -rf "+path
  rimraf.sync path
console.log cowsay.say
  text: "Welcome to the Dota 2 addon generator.\nCreated by Quantum (c) 2014."


#Ask some questions about the game mode
inquirer.prompt([
  {
    type: "input"
    name: "authorname"
    message: "Let's start with your name, please."
    default: "Cool Dude"
  }
  {
    type: "input"
    name: "fullname"
    message: "What is the full name of your game mode?"
    default: "My Addon"
  }
  {
    type: "input"
    name: "name"
    message: "What is the shortname?"
    default: (answers)->
      answers.fullname.replace(/\s/g, '').toLowerCase()
  }
  {
    type: "input"
    name: "classname"
    message: "What would you like to name the game mode class?"
    default: (answers)->
      lingo.camelcase answers.fullname+" Game Mode", true
  }
  {
    type: "input"
    name: "debugout"
    message: "What would you like to ID your addon log output?"
    default: (answers)->
      answers.name.toUpperCase()
  }
  {
    type: "confirm"
    name: "usephysics"
    message: "Would you like to include BMD's physics library?"
    default: true
  }
  {
    type: "input"
    name: "startgold"
    message: "What should be the starting gold?"
    default: 500
    filter: (input)->
      return parseInt input
    validate: (input)->
      input = parseInt input 
      if typeof input isnt "number"
        "You need to enter an integer."
      else
        true
  }
  {
    type: "input"
    name: "maxlevel"
    message: "What should the max level be?"
    default: 50
    filter: (input)->
      return parseInt input
    validate: (input)->
      input = parseInt input 
      if typeof input isnt "number"
        "You need to enter an integer."
      else
        true
  }
], (answers)->
  l c.underline.blue "Copying template to output directory..."
  rm dir("output")
  cpr dir("../barebones"), dir("output")
  rm dir("output/.git")
  rm dir("output/LICENSE")
  rm dir("output/NOTICE")
  rm dir("output/NOTICE")
  l c.underline.blue "Configuring d2moddin..."
  sedi dir("output/info.json"), "BMD", answers.authorname
  sedi dir("output/info.json"), "Barebones", answers.fullname
  sedi dir("output/info.json"), "barebones", answers.name
  l c.underline.blue "Configuring vscripts..."
  mv dir("output/scripts/vscripts/barebones.lua"), dir("output/scripts/vscripts/#{answers.name}.lua")
  sedi dir("output/scripts/vscripts/#{answers.name}.lua"), "BAREBONES", answers.debugout
  sedi dir("output/scripts/vscripts/#{answers.name}.lua"), "BareBonesGameMode", answers.classname
  sedi dir("output/scripts/vscripts/addon_game_mode.lua"), "BareBonesGameMode", answers.classname
  sedi dir("output/scripts/vscripts/addon_init.lua"), "barebones", answers.name
  sedi dir("output/scripts/vscripts/addon_init.lua"), "BAREBONES", answers.debugout
  if not answers.usephysics
    rm dir("output/scripts/vscripts/physics.lua")
    sedi dir("output/scripts/vscripts/addon_init.lua"), "loadModule \\( 'physics' \\)\\n", ""
  sedi dir("output/scripts/vscripts/#{answers.name}.lua"), "barebones", answers.name
  sedi dir("output/scripts/vscripts/#{answers.name}.lua"), "STARTING_GOLD = 500", "STARTING_GOLD = #{answers.startgold}"
  sedi dir("output/scripts/vscripts/#{answers.name}.lua"), "MAX_LEVEL = 50", "MAX_LEVEL = #{answers.maxlevel}"
  l c.underline.blue "Configuring materials..."
  sedi dir("output/materials/overviews/barebones.vmt"), "barebones", answers.name
  mv dir("output/materials/overviews/barebones.vmt"), dir("output/materials/overviews/#{answers.name}.vmt")
  mv dir("output/materials/overviews/barebones.vtf"), dir("output/materials/overviews/#{answers.name}.vtf")
  l c.underline.blue "Configuring translations..."
  sedi dir("output/resource/addon_english.txt"), "BAREBONES", answers.debugout
  sedi dir("output/resource/addon_english.txt"), "Barebones", answers.name
  sedi dir("output/resource/overviews/barebones.txt"), "barebones", answers.name
  mv dir("output/resource/overviews/barebones.txt"), dir("output/resource/overviews/#{answers.name}.txt")
  l c.underline.blue "Configuring shops..."
  mv dir("output/scripts/shops/barebones_shops.txt"), dir("output/scripts/shops/#{answers.name}_shops.txt")
  l c.underline.blue "Configuring maps..."
  mv dir("output/maps/barebones.bsp"), dir("output/maps/#{answers.name}.bsp")
  mv dir("output/maps/barebones.gnv"), dir("output/maps/#{answers.name}.gnv")
  mv dir("output"), dir(answers.name)
  l c.bold.bgGreen "Done! Addon can be found in ./#{answers.name}/"
)
