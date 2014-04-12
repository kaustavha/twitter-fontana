# Twitter Fontana

Twitter search API data visualization tool. So for awesome tweet walls and such.  

**Disclaimer:** I did not write the majority of this library, credits go to the people at EightMedia  

## Example: 

Add transitions.min.css and twitterfontana.min.js to your index and a container for the visualizer 
You also need jquery and twitter-text-js.  

Example in JADE:    

```
doctype html
meta(charset='utf-8')
html
    head
        link(rel='stylesheet', href='./lib/css/transitions.css')
    body
        .fontana
        script(src='./lib/js/jquery.min.js')
        script(src='./lib/js/twitter-text-1.9.0.min.js')    
        script(src='./lib/js/twitterfontana.min.js')
        script(src='./js/script.js')
```

Then in the script, initialize it.  
Example in CoffeeScript:  

```
$ ->   
    settings =
        transition: 'tilt-scroll' 
    #Check animate.css or the twitter fontana plugin page for a list of anim effects

    q = '#hashtag' 
    #twitter search query

    container = $('.fontana')

    OAuth.initialize('your OAuth.io public key here')
    OAuth.popup 'twitter', (err, res)->
        if visualizer
            visualizer.stop()
        datasource = new Fontana.datasources.TwitterSearchFA(q, res)
        visualizer = new Fontana.Visualizer(container, datasource)
        visualizer.start(settings)
        return

    #Set tweet wall to window height since container isnt styled
    container.css 'height', window.innerHeight
```
