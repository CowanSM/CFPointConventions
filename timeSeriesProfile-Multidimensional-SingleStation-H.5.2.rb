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
file.put_att("featureType","timeSeriesProfile")
file.put_att("Conventions","CF-1.6")

p = 4
z = 30
name = 50
profile_dim = file.def_dim("profile",p)
z_dim = file.def_dim("z",z)
name_dim = file.def_dim("name_strlen",name)

lat = file.def_var("lat","float",[])
lat.put_att("units","degrees_north")
lat.put_att("long_name","station latitude")
lat.put_att("standard_name","latitude")

lon = file.def_var("lon","float",[])
lon.put_att("units","degrees_east")
lon.put_att("long_name","station longitude")
lon.put_att("standard_name","longitude")

stationinfo = file.def_var("station_info","int",[])
stationinfo.put_att("long_name","station info")

stationname = file.def_var("station_name","char",[name_dim])
stationname.put_att("cf_role", "timeseries_id")
stationname.put_att("long_name", "station name")

alt = file.def_var("alt","float",[z_dim, profile_dim])
alt.put_att("units","m")
alt.put_att("positive","up")
alt.put_att("axis","Z")

time = file.def_var("time","int",[profile_dim])
time.put_att("long_name","time")
time.put_att("standard_name","time")
time.put_att("units","seconds since 1990-01-01 00:00:00")

temp = file.def_var("temperature","float",[z_dim, profile_dim])
temp.put_att("long_name","Water Temperature")
temp.put_att("units","Celsius")
temp.put_att("coordinates", "time lat lon alt")

# Stop the definitions, lets write some data
file.enddef

lat.put([37.5])
lon.put([-76.5])
stationinfo.put([0])

blank = Array.new(name)
name1 = ("Station1".split(//).map!{|d|d.ord} + blank)[0..name-1]

stationname.put([name1])

time.put( NArray.int(p).indgen!*3600)

alt.put(NArray.float(p*z).indgen!*2.5)

data = NArray.float(p,z).indgen!*0.1
temp.put(data )


file.close
`ncdump -h #{meta_name} > #{cdl_name}`
`ncdump -x -h #{meta_name} > #{ncml_name}`
