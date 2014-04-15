###
# Fontana utils
###

@Fontana ?= {}
@Fontana.utils ?= {}

monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]


@Fontana.utils.prettyDate = (time)->
    date = new Date(time)
    now = (new Date()).getTime()
    diff = ((now - date.getTime()) / 1000)
    day_diff = Math.floor(diff / 86400)

    if isNaN(date)
        return time

    if (isNaN(day_diff) || day_diff < 0 || day_diff >= 1)
        if (day_diff <= 365)
            return "#{date.getDate()} #{monthNames[date.getMonth()]}"
        else
            return "#{date.getDate()} #{monthNames[date.getMonth()]} #{date.getFullYear()}"

    if (!day_diff && diff < 10)
        return "just now"
    if (!day_diff && diff < 60)
        return "#{Math.floor(diff)}s"
    if (!day_diff && diff < 3600)
        return "#{Math.floor(diff / 60)}m"
    if (!day_diff && diff < 86400)
        return "#{Math.floor(diff / 3600)}h"
