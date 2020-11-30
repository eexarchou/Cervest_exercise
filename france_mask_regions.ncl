;----------------------------------------------------------------------
; The "gadm36_FRA_1.shp" shapefile was downloaded from 
; http://www.gadm.org/country/
;----------------------------------------------------------------------

load "./shapefile_utils.ncl"

shpname  = "France_shapefile_gadm/gadm36_FRA_1.shp" 

; --- Print information of the shapefile ---
;print_shapefile_info(shpname)

s = addfile(shpname,"r")
; --- Print names of the regions ---
names              =  s->NAME_1
;print(names)
;-- open data file to get the grid to be used
f = addfile("ERA5_wind/uas/10m_u_component_of_wind_1981_1985.nc4","r")

;-- read variable
var                    =  f->u10(0,:,:)
var@lat2d              =  f->latitude
var@lon2d              =  f->longitude

;-- shapefile mask resources
opt             =  True
opt@return_mask =  True    ;-- this forces the return of a 0s and 1s mask array
opt@shape_var   = "NAME_1"

;-- create mask for each of the 12 regions  
do i=0,dimsizes(names)-1
        namenew2= str_sub_str(names(i), " ","-")
        namenew= str_sub_str(namenew2, "'","-")
        maskname = "mask-"+namenew+".nc" 
        opt@shape_names = names(i)


        ;-- create the mask based on the given shapefile
        mask_array             =  shapefile_mask_data(var, shpname, opt)
        mask_array!0           = "y" 
        mask_array!1           = "x" 
        mask_array@coordinates = "latitude longitude" 

        ;-- create new netCDF file and write mask array
        system("rm -f " + maskname)
        fout = addfile(maskname,"c")

        fout->mask_array     =  mask_array
        fout->latitude       =  f->latitude 
        fout->longitude      =  f->longitude
end do
