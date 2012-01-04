#! ruby

require 'numru/netcdf'
require 'fileutils'

include NumRu

base_name = File.basename(__FILE__).gsub(".rb","")
meta_name = base_name + "/" + base_name + ".nc"
ncml_name = base_name + "/" + base_name + ".ncml"
cdl_name = base_name + "/" + base_name + ".cdl"
FileUtils.mkdir(base_name) unless File.exists?(base_name)

file = NetCDF.create(meta_name)
file.put_att("featureType","timeSeries")
file.put_att("Conventions","CF-1.6")

s = 10
t = 0  #UNLIMITED
name = 50

station_dim = file.def_dim("station",s)
time_dim = file.def_dim("time",t)
name_dim = file.def_dim("name_strlen",name)


lat = file.def_var("lat","sfloat",[station_dim])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","sfloat",[station_dim])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

stationname = file.def_var("station_name","char",[name_dim, station_dim])
stationname.put_att("cf_role", "timeseries_id")
stationname.put_att("long_name", "station name")

alt = file.def_var("alt","sfloat",[station_dim])
alt.put_att("long_name","vertical disance above the surface")
alt.put_att("standard_name","height")
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")

time = file.def_var("time","int",[time_dim])
time.put_att("long_name","time of measurement")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

temp = file.def_var("temperature","sfloat",[station_dim, time_dim])
temp.put_att("long_name","Air Temperature")
temp.put_att("standard_name","air_temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "lat lon alt")

humi = file.def_var("humidity","sfloat",[station_dim, time_dim])
humi.put_att("long_name","Humidity")
humi.put_att("standard_name","specific_humidity")
humi.put_att("units","Percent")
humi.put_att("coordinates", "lat lon alt")



# Stop the definitions, lets write some data
file.enddef

lat.put(NArray.int(s).random!(180))
lon.put(NArray.int(s).random!(180))

blank = Array.new(name)

stats = (0..s-1).map{|n| ("Station-#{n}".split(//).map!{|d|d.ord} + blank)[0..name-1] }
stationname.put(stats)

#time.put(NArray.int(100).random!(3600), "start" => [0], "end" => [99])
time.put(NArray.int(100).indgen!*3600, "start" => [0], "end" => [99])
alt.put(NArray.float(s).random!(10))

temp.put(NArray.float(s,100).random!(40))
humi.put(NArray.float(s,100).random!(90))


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`
