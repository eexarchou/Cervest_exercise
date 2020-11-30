library(s2dverification)
library(ncdf4)
library(tictoc)
library(reshape2)

# --- Clean memory 
rm(list=ls())
gc()

# --- In advance in the terminal 2 operations 
# --- 1. Transformed data to nc4 with "nccopy -k 4 in.nc out.nc4" 
# --- 2. Splitted the nc files in monthly files with "cdo splityearmon
# ---    10m_u_component_of_wind_1981_1985.nc4 10m_u_component_of_wind_" which results
# ---    in 10m_u_component_of_wind_${year}${mon}.nc4 files for each year and easch
# ---    month. 

# Read the masks 
name_regions = c( 
"Auvergne-Rhône-Alpes",
"Bourgogne-Franche-Comté", 
"Bretagne",
"Centre-Val-de-Loire",
"Grand-Est",
"Hauts-de-France",
"Île-de-France",
"Normandie",
"Nouvelle-Aquitaine",
"Occitanie",
"Pays-de-la-Loire",
"Provence-Alpes-Côte-d-Azur"
)

for ( i  in 1:length(name_regions)   )
{
        mask_name = paste0("mask-", name_regions[i],".nc")
        fnc=nc_open(mask_name)

        assign(paste0("mask_", i), ncvar_get(fnc,'mask_array'))
        nc_close(fnc)
}

# --- Read lon/lat (it is useful to Plot to see whether mask is applied
# --- correctly)
fnc  = nc_open('ERA5_wind/uas/10m_u_component_of_wind_198101.nc4')
utmp = ncvar_get(fnc,'u10')
lon = ncvar_get(fnc,'longitude')
lat = ncvar_get(fnc,'latitude')
nc_close(fnc)

# --- Plot the 12 masked regions to make sure masks are correct  
for (region in 1:12) {  
     PlotEquiMap(utmp[,,1]* get(paste0("mask_", region)), lon, lat,
                 filled.continents=F, 
                 fileout=paste0("regions/region_", name_regions[region],".png") )
         } 

# --- Array for the days for each month (40years,12 months) and for each of 
# --- the 12 region where speed > 20mph 
days_maxspeed   = array(0, dim=c( 40, 12, 12 ))
threshold = 20 

# --- "tic" is to count time of execution of the most expensive past of this
# --- script 
tic("Main script")
# --- Loop for the years 
countyear=0
for (year in 1981:2020) { 
        print (paste0("year is ", year))
        # countyear is for indexing the final array
         countyear=countyear+1 

# --- year 2020 velocity data is available only till April  
 lastmonth = 12
 if (year == 2020 ) {
         lastmonth =4 } 

# -- Loop for the months 
 for (month in 1:lastmonth) {
        print (paste0("month is ", month))
         # to create a string with a leading "0", for the name of the nc file 
         mon=formatC(month, width = 2, format = "d", flag = "0") 

# -- Open the u10/v10 data  
        fnc1 = nc_open(paste0('ERA5_wind/uas/10m_u_component_of_wind_',year,mon,'.nc4'))
        fnc2 = nc_open(paste0('ERA5_wind/vas/10m_v_component_of_wind_',year,mon,'.nc4'))
        uas = ncvar_get(fnc1,'u10')
        vas = ncvar_get(fnc2,'v10')
        nc_close(fnc1)
        nc_close(fnc2)
        
        # --- Convert from m/s to mph, and take absolute values  
        uspeed = abs(uas)*2.23694 
        vspeed = abs(vas)*2.23694 
        # --- Replace NA values with 0 
        uspeed[which ( is.na ( uspeed) )] = 0
        vspeed[which ( is.na ( vspeed) )] = 0
        
        # --- If the max value of absolute  u10 and v10 does not exceed theshold, exit loop  
        if ((max(abs(uspeed)) < threshold) && (max(abs(vspeed))< threshold))
                {
                        next
                } 


# --- Loop for the regions  
for (region in 1:12) {  
        # --- Count days with speed larger than threshold
          
        # --- Create the mask for the region with same dimensions as the 
        # --- the velocity, so add a 3rd dimension for time  
        mask = array (0, dim=c (dim(uas)[1],dim(uas)[2],24))
        for (imask in 1:24) {  
                      mask[,,imask] = get(paste0("mask_",region)) 
                             } 
        # --- Loop going over 24hr steps, and see if the threshold is exceeded 
        count <- 1
        day.speed=0
        while (count+23 <= dim(uas)[3] ) {
        tmp1 = uspeed[,,count:(count+23)]* mask   
        tmp2 = vspeed[,,count:(count+23)]* mask  
        if ( (max(tmp1) >= threshold ) | 
             (max(tmp2) >= threshold ) )
                {  
                  day.speed = day.speed + 1 
                } 
                  count = count + 24
                } 
        # --- Array to hold the final data 
        days_maxspeed  [countyear, month, region]  = day.speed 
    } # --- close regions loop 
  } # --- close month loop 
} # --- close year loop
toc()

# --- Save data as Rdata
save.image ("wind.Rdata")

# --- Average over years 
days_maxspeed_ave = Mean1Dim(days_maxspeed,1)

# --- Save data from dataframe and csv file 
df <- data.frame( days_maxspeed_ave)
name_months= c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
colnames(df) <- name_regions
rownames(df) <- name_months
write.csv(df,"days_max_speed.csv")
