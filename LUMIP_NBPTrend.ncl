load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


sensitivity        = "True"    ;true for plotting crop sensitivity simulations, false for generic crops
;sensitivity        = "False"    ;true for plotting crop sensitivity simulations, false for generic crops
;climate            = "True"
climate            = "False"

simyrs             = "185001-201512"
;var                = "GPP"
;var                = "ER"
;var                = "COL_FIRE_CLOSS"
;var                = "LAND_USE_FLUX"
;var                = "EFLX_LH_TOT"
;var                = "TOTSOMC"
;var                = "TOTSOMC_1m"
;var                = "NEE"
;var                = "NEP"
var                = "NBP"

datadir            = "/gpfs/fs1/collections/cdg/timeseries-cmip6/"
print("data directory = "+datadir)
subdir             = "/lnd/proc/tseries/month_1/"
  sim                = "i.e21.IHIST.f09_g17.CMIP6-land-hist.001"
  sim2      = "i.e21.IHIST.f09_g17.CMIP6-land-crop-noIrrig.001"                  ;Treatment simulation
  sim3      = "i.e21.IHIST.f09_g17.CMIP6-land-crop-noFert.001"                  ;Treatment simulation
  sim4      = "i.e21.IHIST.f09_g17.CMIP6-land-crop-noIrrigFert.001"
  sim5      = "i.e21.IHIST.f09_g17.CMIP6-land-noLu.001"                  ;Treatment simulation
  sim6      = "i.e21.IHIST.f09_g17.CMIP6-land-cCO2.001"
  sim7      = "i.e21.IHIST.f09_g17.CMIP6-land-cClim.001"
  sim8      = "i.e21.IHIST.f09_g17.CMIP6-land-crop-grass.001"

  data               =addfile(datadir+sim+subdir+sim+".clm2.h0."+var+"."+simyrs+".nc","r")
  data2              =addfile(datadir+sim2+subdir+sim2+".clm2.h0."+var+"."+simyrs+".nc","r")
  data3              =addfile(datadir+sim3+subdir+sim3+".clm2.h0."+var+"."+simyrs+".nc","r")
  data4              =addfile(datadir+sim4+subdir+sim4+".clm2.h0."+var+"."+simyrs+".nc","r")
  data5              =addfile(datadir+sim5+subdir+sim5+".clm2.h0."+var+"."+simyrs+".nc","r")
  data6              =addfile(datadir+sim6+subdir+sim6+".clm2.h0."+var+"."+simyrs+".nc","r")
  data7              =addfile(datadir+sim7+subdir+sim7+".clm2.h0."+var+"."+simyrs+".nc","r")


;Note: concatenated file; h0 files in LUMIP directory are in 50 year chunks for this sim
  cropdir            = "/glade/p/cesm/lmwg_dev/dll/LUMIP_CombinedSims/"      
  cropdata           = addfile(cropdir+sim8+".clm2.h0."+var+"."+simyrs+".nc","r")



;------- VARIABLES -------------
lat            = data->lat
lon            = data->lon
nlat           = dimsizes(lat)
nlon           = dimsizes(lon)
years          = ispan(1850,2015,1)
month          = ispan(1,12,1)
;For 1996-2015
avgyr          = "1996-2015"
startyr        = (1996 - 1850)
endyr          = (2015 - 1850)
;For 1951-70
;avgyr          = "1951-1970"
;startyr        = (1951 - 1850)
;endyr          = (1970 - 1850)
;For 1D time data
;startyr        = (1996 - 1850)*12
;endyr          = (2015 - 1850)*12 + 11
area           = data->area
landfrac       = data->landfrac
aream          = area*1e6
landarea       = aream*landfrac
crop           = data->$var$
nocrop         = cropdata->$var$
grain1dirr     = data2->$var$
grain1dfer     = data3->$var$
grain1dirf     = data4->$var$
grain1dluc     = data5->$var$
grain1dcco2    = data6->$var$
grain1dcclim   = data7->$var$

landarea!0      = "lat"
landarea&lat    = lat
landarea!1      = "lon"
landarea&lon    = lon


;printVarSummary(crop)
;printVarSummary(nocrop)
;print(dimsizes(month))

ntim           =  dimsizes(crop(:,0,0))
nmon           =  12
nyr            =  ntim/nmon
print(nyr)

if (var .eq. "TLAI") then
  varln     = "Leaf Area Index"
  units     = " (m~S~2~N~ m~S~-2~N~)"
  convert   = 1
end if
if (var .eq. "ER") then
  varln     = "Ecosystem Respiration"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "GPP") then
  varln     = "Gross Primary Productivity"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "NPP") then
  varln     = "Net Primary Productivity"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "FSH") then
  varln     = "Sensible Heat Flux"
  units     = " (W m~S~-2~N~)"
  convert   = 1
end if
if (var .eq. "EFLX_LH_TOT") then
  varln     = "Latent Heat Flux"
  units     = " (W m~S~-2~N~)"
  convert   = 1
end if
if (var .eq. "TOTSOMC") then
  varln     = "Total Soil Organic Matter Carbon"
  units     = " (kg C m~S~-2~N~)"
  convert   = 0.001
end if
if (var .eq. "NEE") then
  varln     = "Net Ecosystem Exchange"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "NEP") then
  varln     = "Net Ecosystem Production"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "NBP") then
  varln     = "Net Biome Production"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "COL_FIRE_CLOSS") then
  varln     = "Fire C Loss"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if
if (var .eq. "LAND_USE_FLUX") then
  varln     = "Land Use Emissions"
  units     = " (g C m~S~-2~N~ day~S~-1~N~)"
  convert   = 60*60*24
end if



datastr   = varln+units

crop = crop*convert
nocrop = nocrop*convert
grain1dirr = grain1dirr*convert
grain1dfer = grain1dfer*convert
grain1dirf = grain1dirf*convert
grain1dluc = grain1dluc*convert
grain1dcco2= grain1dcco2*convert
grain1dcclim=grain1dcclim*convert


;.....Control......
crop4d        = reshape(crop,(/nyr,nmon,nlat,nlon/))
crop4d!2      = "lat"
crop4d&lat    = lat
crop4d!3      = "lon"
crop4d&lon    = lon
cropannual    = dim_avg_n_Wrap(crop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarCoords_n(crop,cropannual,(/1,2/))
;printVarSummary(cropannual)

cropnbp       = dim_avg_n_Wrap(crop4d(endyr-2:endyr,:,{30:},:),(/2,3/))
;cropnbp       = dim_avg_n_Wrap(crop4d(endyr-2:endyr,:,{30:},:),(/2,3/))
cropyravg     = dim_avg_n_Wrap(cropnbp,0)
print(endyr-2+1850 + "-"+(endyr+1850)+ " NBP amplutide with crops = "+(dim_max_n_Wrap(cropyravg,0) - dim_min_n_Wrap(cropyravg,0)))

cropMin     = dim_min_n_Wrap(crop4d(:,:,{30:},:),1)
cropMax     = dim_max_n_Wrap(crop4d(:,:,{30:},:),1)
cropAmp     = (cropMax - cropMin)
copy_VarMeta(cropMax,cropAmp)
;printVarSummary(cropAmp)

landarea3d        = conform_dims(dimsizes(cropAmp),landarea({30:},:),(/1,2/))
copy_VarMeta(cropAmp,landarea3d)

cropAmp1850 = cropAmp(0,:,:)
cropAmpConf = conform_dims(dimsizes(cropAmp),(cropAmp1850),(/1,2/))

cropAmpNorm = cropAmp - cropAmpConf


cropTrend   = dim_sum_n_Wrap(cropAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
cropTrend!0 = "years"
cropTrend&years = years
printVarSummary(cropTrend)
print("NBP Amp diff 1960 = "+cropTrend(110) +"and "+ (endyr+1850) +" = "+cropTrend(endyr))

cropTrendSD = dim_stddev_n_Wrap(cropAmpNorm,(/1,2/))
copy_VarMeta(cropTrend,cropTrendSD)
;printVarSummary(cropTrendSD)

;.....Treatment.....
nocrop4d      = reshape(nocrop,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,nocrop4d)
nocropannual  = dim_avg_n_Wrap(nocrop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,nocropannual)

nocropnpb     = dim_avg_n_Wrap(nocrop4d(endyr-2:endyr,:,{30:},:),(/2,3/))
;nocropnpb     = dim_avg_n_Wrap(nocrop4d(endyr-2:endyr,:,{30:},:),(/2,3/))
nocropyravg   = dim_avg_n_Wrap(nocropnpb,0)
print(endyr-2+1850 + "-"+(endyr+1850)+" NBP amplitude without crops = "+(dim_max_n_Wrap(nocropyravg,0) - dim_min_n_Wrap(nocropyravg,0)))

nocropMin     = dim_min_n_Wrap(nocrop4d(:,:,{30:},:),1)
nocropMax     = dim_max_n_Wrap(nocrop4d(:,:,{30:},:),1)
nocropAmp     = (nocropMax - nocropMin)
copy_VarMeta(nocropMax,nocropAmp)
nocropAmp1850 = nocropAmp(0,:,:)
nocropAmpConf = conform_dims(dimsizes(nocropAmp),(nocropAmp1850),(/1,2/))

nocropAmpNorm = nocropAmp - nocropAmpConf


nocropTrend   = dim_sum_n_Wrap(nocropAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
;nocropTrend   = (nocropTrend - nocropTrend(0))
copy_VarMeta(cropTrend,nocropTrend)
printVarSummary(nocropTrend)
print("NBP generic crop Amp diff 1960 = "+nocropTrend(110) +"and 2015 = "+nocropTrend(endyr))


nocropTrendSD = dim_stddev_n_Wrap(nocropAmpNorm,(/1,2/))
copy_VarMeta(nocropTrend,nocropTrendSD)


;....Sensitivities......
;..no irrigation...
grain1dirr4d    = reshape(grain1dirr,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dirr4d)
grain1dirrann   = dim_avg_n_Wrap(grain1dirr4d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dirrnpb     = dim_avg_n_Wrap(grain1dirr4d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dirryravg  = dim_avg_n_Wrap(grain1dirrnpb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without irrigation = "+(dim_max_n_Wrap(grain1dirryravg,0) - dim_min_n_Wrap(grain1dirryravg,0)))
noirrMin     = dim_min_n_Wrap(grain1dirr4d(:,:,{30:},:),1)
noirrMax     = dim_max_n_Wrap(grain1dirr4d(:,:,{30:},:),1)
noirrAmp     = (noirrMax - noirrMin)
copy_VarMeta(noirrMax,noirrAmp)
noirr1850    = noirrAmp(0,:,:)
noirrAmpConf = conform_dims(dimsizes(noirrAmp),(noirr1850),(/1,2/))
noirrAmpNorm = noirrAmp - noirrAmpConf

noirrTrend   = dim_sum_n_Wrap(noirrAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,noirrTrend)
print("NBP no irr Amp diff 1960 = "+noirrTrend(110) +"and 2015 = "+noirrTrend(165))

noirrTrendSD = dim_stddev_n_Wrap(noirrAmpNorm,(/1,2/))
copy_VarMeta(noirrTrend,noirrTrendSD)


;..no fertilization...
grain1dfert4d    = reshape(grain1dfer,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dfert4d)
grain1dfertann   = dim_avg_n_Wrap(grain1dfert4d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dfertnpb     = dim_avg_n_Wrap(grain1dfert4d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dfertyravg  = dim_avg_n_Wrap(grain1dfertnpb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without fertilization = "+(dim_max_n_Wrap(grain1dfertyravg,0) - dim_min_n_Wrap(grain1dfertyravg,0)))
nofertMin     = dim_min_n_Wrap(grain1dfert4d(:,:,{30:},:),1)
nofertMax     = dim_max_n_Wrap(grain1dfert4d(:,:,{30:},:),1)
nofertAmp     = (nofertMax - nofertMin)
copy_VarMeta(nofertMax,nofertAmp)
nofert1850    = nofertAmp(0,:,:)
nofertAmpConf = conform_dims(dimsizes(nofertAmp),(nofert1850),(/1,2/))
nofertAmpNorm = nofertAmp - nofertAmpConf

nofertTrend   = dim_sum_n_Wrap(nofertAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,nofertTrend)
print("NBP no fert Amp diff 1960 = "+nofertTrend(110) +"and 2015 = "+nofertTrend(endyr))

nofertTrendSD = dim_stddev_n_Wrap(nofertAmpNorm,(/1,2/))
copy_VarMeta(nofertTrend,nofertTrendSD)

;..no irrigation or fertilization...
grain1dirf4d    = reshape(grain1dirf,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dirf4d)
grain1dirfann   = dim_avg_n_Wrap(grain1dirf4d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dirfnpb     = dim_avg_n_Wrap(grain1dirf4d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dirfyravg  = dim_avg_n_Wrap(grain1dirfnpb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without fertilization or irrigation = "+(dim_max_n_Wrap(grain1dirfyravg,0) - dim_min_n_Wrap(grain1dirfyravg,0)))
noirfMin     = dim_min_n_Wrap(grain1dirf4d(:,:,{30:},:),1)
noirfMax     = dim_max_n_Wrap(grain1dirf4d(:,:,{30:},:),1)
noirfAmp     = (noirfMax - noirfMin)
copy_VarMeta(noirfMax,noirfAmp)
noirf1850    = noirfAmp(0,:,:)
noirfAmpConf = conform_dims(dimsizes(noirfAmp),(noirf1850),(/1,2/))
noirfAmpNorm = noirfAmp - noirfAmpConf

noirfTrend   = dim_sum_n_Wrap(noirfAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,noirfTrend)

noirfTrendSD = dim_stddev_n_Wrap(noirfAmpNorm,(/1,2/))
copy_VarMeta(noirfTrend,noirfTrendSD)


;..no land use change...
grain1dluc4d    = reshape(grain1dluc,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dluc4d)
grain1dlucann   = dim_avg_n_Wrap(grain1dluc4d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dlucnpb     = dim_avg_n_Wrap(grain1dluc4d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dlucyravg  = dim_avg_n_Wrap(grain1dlucnpb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without land use change = "+(dim_max_n_Wrap(grain1dlucyravg,0) - dim_min_n_Wrap(grain1dlucyravg,0)))
nolucMin     = dim_min_n_Wrap(grain1dluc4d(:,:,{30:},:),1)
nolucMax     = dim_max_n_Wrap(grain1dluc4d(:,:,{30:},:),1)
nolucAmp     = (nolucMax - nolucMin)
copy_VarMeta(nolucMax,nolucAmp)
noluc1850    = nolucAmp(0,:,:)
nolucAmpConf = conform_dims(dimsizes(nolucAmp),(noluc1850),(/1,2/))
nolucAmpNorm = nolucAmp - nolucAmpConf

nolucTrend   = dim_sum_n_Wrap(nolucAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,nolucTrend)

nolucTrendSD = dim_stddev_n_Wrap(nolucAmpNorm,(/1,2/))
copy_VarMeta(nolucTrend,nolucTrendSD)


;..no CO2 fertilization...
grain1dcco24d    = reshape(grain1dcco2,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dcco24d)
grain1dcco2ann   = dim_avg_n_Wrap(grain1dcco24d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dcco2npb     = dim_avg_n_Wrap(grain1dcco24d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dcco2yravg  = dim_avg_n_Wrap(grain1dcco2npb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without CO2 fertilization = "+(dim_max_n_Wrap(grain1dcco2yravg,0) - dim_min_n_Wrap(grain1dcco2yravg,0)))
nocco2Min     = dim_min_n_Wrap(grain1dcco24d(:,:,{30:},:),1)
nocco2Max     = dim_max_n_Wrap(grain1dcco24d(:,:,{30:},:),1)
nocco2Amp     = (nocco2Max - nocco2Min)
copy_VarMeta(nocco2Max,nocco2Amp)
nocco21850    = nocco2Amp(0,:,:)
nocco2AmpConf = conform_dims(dimsizes(nocco2Amp),(nocco21850),(/1,2/))
nocco2AmpNorm = nocco2Amp - nocco2AmpConf

nocco2Trend   = dim_sum_n_Wrap(nocco2AmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,nocco2Trend)

nocco2TrendSD = dim_stddev_n_Wrap(nocco2AmpNorm,(/1,2/))
copy_VarMeta(nocco2Trend,nocco2TrendSD)


;..no climate change...
grain1dcclim4d    = reshape(grain1dcclim,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,grain1dcclim4d)
grain1dcclimann   = dim_avg_n_Wrap(grain1dcclim4d(startyr:endyr,:,{30:},:), (/2,3/))
grain1dcclimnpb     = dim_avg_n_Wrap(grain1dcclim4d(endyr-2:endyr,:,{30:},:),(/2,3/))
grain1dcclimyravg  = dim_avg_n_Wrap(grain1dcclimnpb,0)
print(endyr-2+1850+ "-" + (endyr+1850) + " NBP amplutide without climate change = "+(dim_max_n_Wrap(grain1dcclimyravg,0) - dim_min_n_Wrap(grain1dcclimyravg,0)))
nocclimMin     = dim_min_n_Wrap(grain1dcclim4d(:,:,{30:},:),1)
nocclimMax     = dim_max_n_Wrap(grain1dcclim4d(:,:,{30:},:),1)
nocclimAmp     = (nocclimMax - nocclimMin)
copy_VarMeta(nocclimMax,nocclimAmp)
nocclim1850    = nocclimAmp(0,:,:)
nocclimAmpConf = conform_dims(dimsizes(nocclimAmp),(nocclim1850),(/1,2/))
nocclimAmpNorm = nocclimAmp - nocclimAmpConf

nocclimTrend   = dim_sum_n_Wrap(nocclimAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))
copy_VarMeta(cropTrend,nocclimTrend)

nocclimTrendSD = dim_stddev_n_Wrap(nocclimAmpNorm,(/1,2/))
copy_VarMeta(nocclimTrend,nocclimTrendSD)

print("entering Combined Data")

;.....CombinedData......

AllTrends         = new((/7,nyr/),float)
AllTrends!1       = "years"
AllTrends&years   = years

AllTrends(0,:)    =(/cropTrend/)
AllTrends(1,:)    =(/nocco2Trend/)
AllTrends(2,:)    =(/nocclimTrend/)
AllTrends(3,:)    =(/noirrTrend/)
AllTrends(4,:)    =(/nofertTrend/)
AllTrends(5,:)    =(/nocropTrend/)
AllTrends(6,:)    =(/nolucTrend/)
;note: may want to remove nocropTrend if keeping in other figure
;also may want to update noLUC to be normalized...

climUSGrainC      = new((/3,nyr/),float)
climUSGrainC!1    = "years"
climUSGrainC&years= years
printVarSummary(climUSGrainC) 

climUSGrainC(0,:) = (/cropTrend/)
climUSGrainC(1,:) = (/nocco2Trend/)
climUSGrainC(2,:) = (/nocclimTrend/)


if (sensitivity .eq. "True") then

print("sensitivity = "+sensitivity)
print("working1")

  psstr     = "_Management_"

  USGrainC      = new((/3,nyr/),float)
  USGrainC!1    = "years"
  USGrainC&years= years
  printVarSummary(USGrainC)

  USGrainC(0,:) = (/cropTrend/)
  USGrainC(1,:) = (/noirrTrend/)
  USGrainC(2,:) = (/nofertTrend/)

  grainSD     = new((/2,nyr/),float)
  grainSD!1   = "years"
  grainSD&years = years
  grainSD(0,:)  = cropTrend + cropTrendSD
  grainSD(1,:)  = cropTrend - cropTrendSD

  irrigSD     = grainSD
  irrigSD(0,:)  = noirrTrend + noirrTrendSD
  irrigSD(1,:)  = noirrTrend - noirrTrendSD

  fertSD      = grainSD
  fertSD(0,:)  = nofertTrend + nofertTrendSD
  fertSD(1,:)  = nofertTrend - nofertTrendSD

  lucSD       = grainSD
  lucSD(0,:)  = nolucTrend + nolucTrendSD
  lucSD(1,:)  = nolucTrend - nolucTrendSD

  noirfSD     = grainSD
  noirfSD(0,:)= noirfTrend + noirfTrendSD
  noirfSD(1,:)= noirfTrend - noirfTrendSD


else
  psstr     = "_GenericCrop_"

  USGrainC      = new((/2,nyr/),float)
  USGrainC!1    = "years"
  USGrainC&years= years
  printVarSummary(USGrainC)

  USGrainC(0,:) = (/cropTrend/)
  USGrainC(1,:) = (/nocropTrend/)

  nograinSD     = USGrainC
  nograinSD(0,:)= nocropTrend + nocropTrendSD 
  nograinSD(1,:)= nocropTrend - nocropTrendSD

  grainSD       = USGrainC
  grainSD(0,:)  = cropTrend + cropTrendSD
  grainSD(1,:)  = cropTrend - cropTrendSD

end if



;************* PLOTTING **************
res                        = True
;wks             = gsn_open_wks ("pdf", var+psstr+"LUMIP_Timeseries_NorthernHem")
wks             = gsn_open_wks ("pdf", var+psstr+"LUMIP_Timeseries_NorthernHem_ALL")

res@xyDashPattern          = 0
res@gsnMaximize            = True
res@gsnFrame               = False
res@tiXAxisString          = "Year"
res@tiYAxisString          = "~F33~D ~F21~ NBP Amplitude"+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res@gsnYRefLine            = 0.0
res@gsnYRefLineDashPattern = 1
res@gsnYRefLineThicknessF  = 1.5
res@xyLineThicknessF       = 3
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"


if (sensitivity .eq. "True") then

;print("sensitivity true")

;  res@xyExplicitLegendLabels = (/" CLM5",  " No Irrigation", " No Fertilization"/)
;  res@lgItemOrder            = (/2,1,0/)    ; reorders the legend labels
;  res@xyLineColors           = (/"purple4","dodgerblue3","darkorange"/)
  res@xyExplicitLegendLabels = (/" CLM5"," No CO2"," No Climate Change", " No Irrigation", " No Fertilization","Generic Crop"," No LUC" /)
  res@lgItemOrder            = (/6,5,4,3,2,1,0/)    ; reorders the legend labels
  res@xyLineColors           = (/"purple4", "olivedrab", "coral3", "steelblue3", "red3", "grey70", "goldenrod1"/) 

;  res@pmLegendParallelPosF   = .12                 ; move units right; note: used 0.25 for nocrop
  res@pmLegendParallelPosF   = .145                ; move units right; note: used 0.25 for nocrop
  res@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
  res@pmLegendWidthF         = 0.075               ; Change width and
  res@pmLegendHeightF        = 0.18                ; height of legend.
  res@lgLabelFontHeightF     = .01                 ; label font height

else
  res@xyExplicitLegendLabels = (/" Active Crops", " Generic Crops"/)         ; create explicit labels
  res@lgItemOrder            = (/1,0/)    ; reorders the legend labels

  res@pmLegendParallelPosF   = .14                 ; move units right; note: used 0.25 for nocrop
  res@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
  res@pmLegendWidthF         = 0.075               ; Change width and
  res@pmLegendHeightF        = 0.18                ; height of legend.
  res@lgLabelFontHeightF     = .01                 ; label font height
  res@xyLineColors           = (/"purple4","olivedrab"/)
end if




if (var .eq. "NBP") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 1.2
end if

print("plotting")
;plotlines                 = gsn_csm_xy(wks,years,USGrainC,res)
plotlines                 = gsn_csm_xy(wks,years,AllTrends,res)



;.......clim plot.........
res2                        = True
wks2             = gsn_open_wks ("pdf", var+"climate_LUMIP_Timeseries_NorthernHem")

res2@xyDashPattern          = 0
res2@gsnMaximize            = True
res2@gsnFrame               = False
res2@tiXAxisString          = "Year"
res2@tiYAxisString          = "~F33~D ~F21~ NBP Amplitude"+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res2@gsnYRefLine            = 0.0
res2@gsnYRefLineDashPattern = 1
res2@gsnYRefLineThicknessF  = 1.5
res2@xyLineThicknessF       = 3
res2@pmLegendDisplayMode    = "Always"
res2@pmLegendSide           = "Top"


res2@xyExplicitLegendLabels = (/" CLM5",  " No CO~B~2~N~ Fertilization", " No Climate Change"/)
res2@lgItemOrder            = (/2,1,0/)    ; reorders the legend labels
res2@xyLineColors           = (/"purple4","red","black"/)

res2@pmLegendParallelPosF   = .15                 ; move units right; note: used 0.25 for nocrop
res2@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res2@pmLegendWidthF         = 0.075               ; Change width and
res2@pmLegendHeightF        = 0.18                ; height of legend.
res2@lgLabelFontHeightF     = .01                 ; label font height


if (var .eq. "NBP") then
  res2@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res2@trYMaxF                = 1.2
end if

print("plotting")
plotlines                 = gsn_csm_xy(wks2,years,climUSGrainC,res2)

















