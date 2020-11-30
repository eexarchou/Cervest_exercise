###  Exercise 

General comments:    
 
Another way to approach it perhaps faster would be to do a 1-hr climatology for
all grids for each component u10m/v10m separately (so: each grid is a time means
of 40 values for the 40 years time series), identify for each grid point the
extreme values (which are already smoothed in this climatology, so they are not
expected to exceed the 20mph threshold) by -let’s say- using the 90% percentile.
Then identify which of the analysed regions have a 90th percentile value which
is closer to a given threshold. Those regions are the most likely to have more
days with wind values above 20mph. Focusing on these regions while masking out
the rest, using the full time series, saves computational time, and might be
useful when checking larger datasets (addressing also question 4 below). 

The bottleneck here is to construct the 1-hr climatology.  So either I would use
daily values instead (regions with high daily values are more likely to have
higher 1-hourly values).    

Or, keep the 1-hourly values but interpolate data into
a coarser grid (perhaps when we have global data instead for one country only). 
After identifying regions of interest, I would use directly the
original grid.         

A third option without losing much information would be to break the files into
snaller chunks (like the 12 regions here) and then construct a climatology per
region. 

### Follow up questions 

1. How long does your program take to execute on your machine?

The nccopy and cdo commands took about 1 hour.  The NCL script to create the
mask for the regions in France is very fast (about 1 minute).  The R script took about 40 min.  

2. Which parts of your program take the longest? Is your program CPU-bound or
IO-bound?

The Rscript is the most time consuming. It is IO-bound because it has to read a
long list of velocity files. 

3. What would you suggest to make this task faster? Roughly how fast do you think
it is possible to do this on a single personal computer?

The first time consuming task was to look for resources which I did not have
(shapefiles etc), and create the regional masks asked in this exercise. Once
those are in place, it was also a time consuming task to run the R script. To
make it faster I would filter regions by creating climatologies (see my comment
above) and identifying which regions have the highest winds, and run the script
only for those regions rather than for the whole country.  

4. How would you scale this up in order to be able to process data for all of
Europe or even the entire world?

I would proceed with constructing the 1-hour climatology (which is the most
demanding part, but it can be broken down into smaller regions), identify the
90th percentile for each grid point, and following that identify the regions
with the highest values, and focus only on those regions while masking out the
rest.  

5. What have you done to verify that your output is correct?

For the NCL mask outputs I could visualize they are correct (with ncview for
example). For the R script I also created the png files with the regional maps
of France.  Also, for the actual computation, I run it for 5 years, and did the
same computations with cdo and I checked whether I got same results. 

6. What are the advantages and limitations of the approach you have taken?

Advantages are that I could do this in a personal computer without any extra
resources (memory) needed. Limitations: it took considerable time to complete.   

7. Discuss some of the assumptions and choices you have made.

I broke down files to monthly because it requires less memory to run and makes
it possible to run in a personal computer. 

8. Do you think this answers the cyclist’s questions? In other words, do you think
this analysis is decision-useful?    

It is useful to do this analysis, but I would change the delivered message.
A more simplified index could be more useful, such as one indicating which are
the windiest regions for each month, and which are the ones with less wind.  
To further explore this issue I would look more into
cyclists problems in relation to the wind speed, for example, 
if wind gusts are a problem for cyclists, and how to deal with those in ERA5. 

9. What are the sources of uncertainty in this analysis? How would you quantify
uncertainty?

Uncertainty comes from the choice of reanalysis data. To properly assess this,
the analysis should be done with at least 2 datasets, for example ERA5 and NCEP. 

10. What are some possible limitations and sources of bias in the ERA5 data and in
this analysis? How would you address this?

I would look carefully into the documentation of ERA5 on the ECMWF [site].
There is also [literature] of such assessments, published for different
variables.  Even if such assessments are for different variables in the above
examples, they might provide some useful information since the fields are part
of a dynamical system (for example biased wind speed would affect surface
turbulent fluxes, or biases in cloud cover would affect surface temperature).       

11. Do you have any additional thoughts and considerations you would like to
    share?  
    
I enjoyed doing this excercise, and I learned something new: shapefiles, and how
to work with them. I was not aware of shapefiles and their usefulness, or that
they can be used in a relatively easy way with NCL (I am sure there are R/python
libraries too).  

    
[site]: https://www.ecmwf.int/en/newsletter/161/meteorology/use-era5-reanalysis-initialise-re-forecasts-proves-beneficial  
[literature]: https://www.sciencedirect.com/science/article/pii/S0038092X18301920 
