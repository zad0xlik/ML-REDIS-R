//lets create an API to twitter now and connect to their data streamer

import org.apache.spark.streaming._
import org.apache.spark.streaming.twitter._
import org.apache.spark.storage.StorageLevel
import scala.io.Source
import scala.collection.mutable.HashMap
import java.io.File
import org.apache.log4j.Logger
import org.apache.log4j.Level
import sys.process.stringSeqToProcess

/** Configures the Oauth Credentials for accessing Twitter */
def configureTwitterCredentials(apiKey: String, apiSecret: String, accessToken: String, accessTokenSecret: String) {
  val configs = new HashMap[String, String] ++= Seq(
    "apiKey" -> apiKey, "apiSecret" -> apiSecret, "accessToken" -> accessToken, "accessTokenSecret" -> accessTokenSecret)
  println("Configuring Twitter OAuth")
  configs.foreach{ case(key, value) =>
    if (value.trim.isEmpty) {
      throw new Exception("Error setting authentication - value for " + key + " not set")
    }
    val fullKey = "twitter4j.oauth." + key.replace("api", "consumer")
    System.setProperty(fullKey, value.trim)
    println("\tProperty " + fullKey + " set as [" + value.trim + "]")
  }
  println()
}

// Configure Twitter credentials
val apiKey = "OhXZiVgWC35G6qCcThcGVRzp8"
val apiSecret = "238vyz7ygwGcFt3NunsPM53Ao8x155FoydZJVVaZ9Z0kNHsgmo"
val accessToken = "1650990344-6sjHQ1vFLM1z2Zc9gOtdxMloo5RpKR1mg5O4Lfk"
val accessTokenSecret = "5gXeuwDDw7hGeK5Ypj5Zli9tl4xQlup9910HOv5MqjVt4"

configureTwitterCredentials(apiKey, apiSecret, accessToken, accessTokenSecret)

import org.apache.spark.streaming.twitter._
val ssc = new StreamingContext(sc, Seconds(2))
val tweets = TwitterUtils.createStream(ssc, None)
val twt = tweets.window(Seconds(60))

case class Tweet(createdAt:Long, text:String)
twt.map(status=>
  Tweet(status.getCreatedAt().getTime()/1000, status.getText())
).foreachRDD(rdd=>
  rdd.registerAsTable("tweets")
)

twt.print

ssc.start()


//let's run sql commands on streaming data:
%sql select * from tweets where text like '%girl%' limit 10

//this is like yoda on stereoids
//let's do a streaming time series 
%sql select createdAt, count(1) from tweets group by createdAt order by createdAt


//You can make user-defined function and use it in Spark SQL. Let's try it by making function named sentiment.
//This function will return one of the three attitudes(positive, negative, neutral) towards the parameter.

def sentiment(s:String) : String = {
    val positive = Array("like", "love", "good", "great", "happy", "cool", "the", "one", "that")
    val negative = Array("hate", "bad", "stupid", "is")

    var st = 0;

    val words = s.split(" ")    
    positive.foreach(p =>
        words.foreach(w =>
            if(p==w) st = st+1
        )
    )

    negative.foreach(p=>
        words.foreach(w=>
            if(p==w) st = st-1
        )
    )
    if(st>0)
        "positivie"
    else if(st<0)
        "negative"
    else
        "neutral"
}
sqlc.registerFunction("sentiment", sentiment _)

//let's graph the data
%sql select sentiment(text), count(1) from tweets where text like '%girl%' group by sentiment(text)