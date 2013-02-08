module.exports =

  Spout: require "./spout"
  
  Stream: require "./stream"

  TwitterSpout: require "./twitter-spout"


spout1 = new module.exports.TwitterSpout
  #"consumer_key": "66ST16sJgjJdHekmhM3LnA"
  #"consumer_secret": "k6rchZItE67ZBju4ZXqjcoETPwLXC7YANl8oYCrfo"
  #"access_token": "325130641-5kac7j2V7zE8T0kC2XEnr33oRecrAef5djhPD8UH"
  #"access_token_secret": "AnNTnyuguaTmvwkE68fAcgUXn6cMABX5u28VifFLk"
  "consumer_key": "91SDnh8OqubgzL5tx3fkyw"
  "consumer_secret": "mcoDcN7QKS1MyckSSuOaNEEMeQ0liBpCgy9HYv87eoo"
  "access_token": "1149814628-AtHk0wExCqKCdVkYBgsJL9Mp4T7ftJSPBxUB6zf"
  "access_token_secret": "gDyCcvpPPmKSaolS0ZdUUfnBn9xpyt8jv6q8VWdrwM"


# Operators
#   filters
#   injectors (storms calls these functions)
#   project
#   aggregators
#     storm supports combinerAggregtor, reducerAggregtor and aggregator
#     storm also allows chaining aggregagators to emit mulitple aggregates over same partition
#     perhaps this can all be simplified by providing default aggregators as well as an aggregote interface
#       also each aggregator could be provided a window type (sliding, tumbling), length/time, and emit frequency
#     groupBy streams?
#   merge
#   join




connect = new module.exports.Stream(spout1).project( (data) -> return data.id_str ).sink( (data) -> console.log data )
