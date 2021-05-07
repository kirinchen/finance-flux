import "date"
import "math"

trAvgCount30= from(bucket: "quote")
  |> range(start: -30d, stop:v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "daily" and
    (r.valmean == "volume"  or
    r.valmean == "open") and
    r.name == "bitcoin"
  )
  |> map(fn: (r) => ({ r with _time: date.truncate(t: r._time, unit: 1d)    }))
  |> pivot(rowKey:["_time"], columnKey: ["valmean"], valueColumn: "_value")
  |> map(fn: (r) => ({ r with _value: r.volume / r.open }))  
  |>mean()
  |> findColumn(
    fn: (key) => true,
    column: "_value"
  )    

  priceAvg30 = from(bucket: "quote")
  |> range(start: -30d, stop:v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "daily" and
    r.valmean == "open" and
    r.name == "bitcoin"
  )
  |> mean()
  |> findColumn(
    fn: (key) => true,
    column: "_value"
  )  


t1 = from(bucket: "quote")
  |> range(start: v.timeRangeStart, stop:v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "realtime" and
    r.symbol == "BTC" 
  )
  |> map(fn: (r) => ({ r with _time: date.truncate(t: r._time, unit: 1s) }))
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({ r with count24: r.volume_24h / r.price  }))
  |> map(fn: (r) => ({ r with countRate24: r.count24 / trAvgCount30[0]  }))
  |> map(fn: (r) => ({ r with priceRate: (r.price-priceAvg30[0])/priceAvg30[0]  }))
  |> map(fn: (r) => ({ r with _value: (r.countRate24 * r.priceRate) *10.00 ,alias:"及時買賣壓" }))
  t1


