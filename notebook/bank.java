val bankText = sc.textFile("/mnt/bank-full.csv")

case class Bank(age:Integer, job:String, marital : String, education : String, balance : Integer)

val bank = bankText.map(s=>s.split(";")).filter(s=>s(0)!="\"age\"").map(
    s=>Bank(s(0).toInt, 
            s(1).replaceAll("\"", ""),
            s(2).replaceAll("\"", ""),
            s(3).replaceAll("\"", ""),
            s(5).replaceAll("\"", "").toInt
        )
)

bank.registerTempTable("bank")

%sql select age, count(1) from bank where age < 30 group by age order by age

%sql select age, count(1) from bank where age < ${maxAge=30} group by age order by age

%sql select age, count(1) from bank where marital="${marital=single,single|divorced|married}" group by age order by age