###
# Fontana Datasources

There are three different types of Datasources:

 * Fontana.datasources.Static
 * Fontana.datasources.HTML
 * Fontana.datasources.TwitterSearch

Each datasource implements a `getMessages` method that takes a callback.
The callback is called with a list of messages in the following format:

``` javascript
{
    'id': 'unique-id',
    'created_at': new Date().toString(),
    'text': 'A fake Tweet, in a fake JSON response',
    'user': {
        'name': 'Tweet Fontana',
        'screen_name': 'tweetfontana',
        'profile_image_url': '/img/avatar.png'
    }
}
```

Note that this is the minimum set of keys, some implementations (most notabily
the Twitter datasource) will provide a richer set of keys.
###

@Fontana ?= {}
@Fontana.datasources ?= {}


class @Fontana.datasources.Static
    ###
    The Static datasource is constructed with a list of messages.
    * setMessages extendeds the list of messages.
    * getMessages will call a callback with the same list of messages.
    ###
    constructor: (@messages=[])->

    setMessages: (messages)->
        @messages ?= []
        @mesages = messages.concat(@mesages)

    getMessages: (callback)->
        # setTimeout makes this async
        if callback
            setTimeout((=> callback(@messages)), 0)


class @Fontana.datasources.HTML
    ###
    The HTML datasource should be initialized with a jQuery node.
    * extractMessages returns the messages found in the given node, it
      extracts the content from a specific HTML structure e.g.:
      ```
      <div id="unique-message-id" class="message">
          <img class="avatar" src="/img/avatar.png">
          <span class="name">Tweet Fontana</span>
          <span class="screen_name">@tweetfontana</span>
          <p class="text">This is a fake tweet</p>
      </div>
      ```
      Only the id and class names are important.
    * getMessages uses extractMessages to keep a running list of messages.
      It calls the callback with this list. Repeated calls to getMessages
      will extract new messages from the same node.
    ###
    constructor: (@container)->
        @messages = []

    extractMessages: ->
        messages = []
        $('.message', @container).each((i, message)->
            messages.push({
                id: message.id
                created_at: new Date().toString()
                text: $('.text', message).text()
                user: {
                    name: $('.name', message).text()
                    screen_name: $('.screen_name', message).text().replace(/^@/, '')
                    profile_image_url: $('.avatar', message).attr('src')
                }
            }))
        return messages

    getMessages: (callback)->
        ids = [m.id for m in @messages]
        messages = []
        @extractMessages().forEach((message)->
            if message.id not in ids
                messages.push(message))
        @messages = messages.concat(@messages)
        # setTimeout makes this async
        if callback
            setTimeout((=> callback(@messages)), 0)


class @Fontana.datasources.TwitterSearch
    ###
    This datasource performs a search using the Twitter API and provides
    the callback with the results. Repeated calls to getMessages will
    expand the list of messages with new search results.

    Because of API limits the minimum time between actual searches
    is 5 seconds (180 searches in a 15 minute).
    ###
    min_interval = 60000 * 15 / 180

    constructor: (@q)->
        @params = {
            since_id: 1
            q: @q
            result_type: 'recent'
        }
        @lastCall = 0
        @messages = []
        @getJSON = $.getJSON('/api/twitter/search/', @params)

    getMessages: (callback)->
        now = (new Date()).getTime()
        if now - @lastCall < min_interval
            if callback
                setTimeout((=> callback(@messages)), 0)
        else
            @lastCall = (new Date()).getTime()
            @getJSON
                .success((data)=>
                    if data.statuses.length
                        @messages = data.statuses.concat(@messages)
                        @params['since_id'] = @messages[0].id_str
                    if callback
                        if @messages.length
                            callback(@messages)
                        else
                            callback([
                                id: (new Date()).getTime()
                                created_at: new Date().toString()
                                text: 'Your search term returned no Tweets :('
                                user:
                                    name: 'Twitter Fontana'
                                    screen_name: 'twitterfontana'
                                    profile_image_url: '/img/avatar.png'
                            ])
                )
                .error(->
                    if callback
                        callback([
                            id: (new Date()).getTime()
                            created_at: new Date().toString()
                            text: 'Error fetching tweets :('
                            user:
                                name: 'Twitter Fontana'
                                screen_name: 'twitterfontana'
                                profile_image_url: '/img/avatar.png'
                        ])
                )


class @Fontana.datasources.TwitterSearchFA extends @Fontana.datasources.TwitterSearch
    ###
    Same as the Twitter search datasource but allows:
    -- Different twitter api url
    -- Uses an authenticated http service passed in,
     such as an authenticated OAuth.io response, but others with the correct headers set should work as well
    ###
    constructor: (@q, @http, @url)->
        super(@q)
        if !@url?
            @url = "https://api.twitter.com/1.1/search/tweets.json"
        @getJSON = @http.get(            
            url: @url
            data: @params
            dataType: 'json')