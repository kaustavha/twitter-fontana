###
# CoffeeScript implementation of nano.js by kaustavha
# Nano is a templating engine by Tomasz Mazur & Jacek Bacela
# https://github.com/trix/nano
###

nano = (template, data) ->
    template.replace /\{([\w\.]*)\}/g, (str, key) ->
        keys = key.split("."); v = data[keys.shift()]; v = v[key] for key in keys        
        `(typeof v !== "undefined" && v !== null) ? v : ""`