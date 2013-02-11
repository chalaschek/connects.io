{SumStat, CountStat} = require "./stat"

module.exports =

  Spout: require "./spout"
  
  Stream: require "./stream"

  TwitterSpout: require "./twitter-spout"

  Aggregator : require "./aggregator"

  SumStat : SumStat

  CountStat : CountStat

  SlidingTimeWindow : require("./sliding-window").SlidingTimeWindow


spout1 = new module.exports.TwitterSpout
  "consumer_key": "91SDnh8OqubgzL5tx3fkyw"
  "consumer_secret": "mcoDcN7QKS1MyckSSuOaNEEMeQ0liBpCgy9HYv87eoo"
  "access_token": "1149814628-AtHk0wExCqKCdVkYBgsJL9Mp4T7ftJSPBxUB6zf"
  "access_token_secret": "gDyCcvpPPmKSaolS0ZdUUfnBn9xpyt8jv6q8VWdrwM"

connect = new module.exports.Stream(spout1)
          #.filter( (data, cb) -> 
          #  return cb null, data if Math.random() > .5
          #  return cb()
          #)
          .project( (data, cb) ->
            tags = []
            #for tag in data.entities?.hashtags
            #  _norm = tag.text.toLowerCase()
            #  if _norm is "lol" or _norm is "rice" then tags.push _norm
            tags = data.entities?.hashtags?.map (tag) -> tag.text.toLowerCase()
            return cb null, {id: data?.id, tags: tags} )
          .inject( ( data, cb)-> return cb null, {injectDate: new Date(), text: "I love #{data.tags.join(' ')}"} )
          .aggregate( new module.exports.Aggregator
            window          : new module.exports.SlidingTimeWindow 5000
            stats           : [ new SumStat("id"), new CountStat("id") ]
            cumulative      : false
            #groupBy         : "tags"
            emitFrequency   : 500
          )
          .sink (data) ->
            console.log data

