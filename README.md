# archive flux

## price dif 

### MA

```flux
import "strings"
from(bucket: "quote")
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
   |> filter(fn: (r) =>
    r._measurement == "realtime" and
    r.symbol == "${symbol}" 
  )
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({ r with _value: (r.low + r.close + r.high)/3.0 }))    
  |> timeShift(duration: 5m)  
  |> map(fn: (r) => ({ r with orgv: r._value }))  
  |> difference()
  |> movingAverage(n: int( v: strings.replaceAll(v: "${period}", t: "m", u: ""))/5 )
  |>map(fn: (r) => ({ r with _value: if ${rated} then r._value/r.orgv else r._value }))   
  |>map(fn: (r) => ({ r with alias: "MA" }))   
```

