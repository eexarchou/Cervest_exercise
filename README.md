# Shapefile_exercise

Steps taken 

1. I transformed the u10/v10m data with       
   `nccopy -k 4 10m_u_component_of_wind_1981_1985.nc 10m_u_component_of_wind_1981_1985.nc4` 

2. I applied a cdo command for splitting data into smaller pieces, so that they
   require less memory in the R script:     
   `cdo splitmonyear 10m_u_component_of_wind_1981_1985.nc4 10m_u_component_of_wind` 

3. I obtained shapefiles for regions in France from <http://www.gadm.org/country/>

4. I created a mask for each region in France, named `mask-${region-name}.nc` with    
   `ncl france_mask_regions.ncl`

5. Use the above masks in the data to calculate 
   - Days with max speed > 20mph, and
   - Days with (u10 or v10m) > 20 mph    
   with  `Rscript wind.R` 

6. Outputs
  -   for wind speed 
  -   png files in the directory `regions`,
as an output of `wind.R`.   
  
