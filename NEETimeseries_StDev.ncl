load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


;sensitivity        = "True"    ;true for plotting crop sensitivity simulations, false for generic crops
sensitivity        = "False"    ;true for plotting crop sensitivity simulations, false for generic crops

simyrs             = "185001-201012"
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

datadir            = "/glade/p/cgd/tss/people/oleson/CLM_LAND_ONLY_RELEASE/"
model              = "CLM5/"
datadir            = datadir + model
print("data directory = "+datadir)
subdir             = "/lnd/proc/tseries/month_1/"
sim                = "clm50_r267_1deg_GSWP3V1_iso_hist"
data               =addfile(datadir+sim+subdir+sim+".clm2.h0."+var+"."+simyrs+".nc","r")

  sim2      = "clm50_r270_1deg_GSWP3V1_NoIrrig_hist"                  ;Treatment simulation
  sim3      = "clm50_r270_1deg_GSWP3V1_NoFert_hist"                  ;Treatment simulation
  sim4      = "clm50_r270_1deg_GSWP3V1_NoIrrigNoFert_hist"
  sim5      = "clm50_r270_1deg_GSWP3V1_NoLULCC_hist"                  ;Treatment simulation

  data2              =addfile(datadir+sim2+subdir+sim2+".clm2.h0."+var+"."+simyrs+".nc","r")
  data3              =addfile(datadir+sim3+subdir+sim3+".clm2.h0."+var+"."+simyrs+".nc","r")
  data4              =addfile(datadir+sim4+subdir+sim4+".clm2.h0."+var+"."+simyrs+".nc","r")
  data5              =addfile(datadir+sim5+subdir+sim5+".clm2.h0."+var+"."+simyrs+".nc","r")

  nocropdir          = "/glade/p/cesm/lmwg_dev/dll/CLM5GSWP3_NoCrop/SingleVarTimeFiles/"
  cropsim            = "clm50_r267_1deg_GSWP3V1_iso_hist_nocrop_transientfix"
  cropdata           =addfile(nocropdir+cropsim+".clm2.h0."+var+"."+simyrs+".nc","r")

;ADD NO CO2 DATA


;------- VARIABLES -------------
lat            = data->lat
lon            = data->lon
nlat           = dimsizes(lat)
nlon           = dimsizes(lon)
years          = ispan(1850,2010,1)
month          = ispan(1,12,1)
;For 1990-2010
avgyr          = "1991-2010"
startyr        = (1991 - 1850)
endyr          = (2010 - 1850)
;For 1951-70
;avgyr          = "1951-1970"
;startyr        = (1951 - 1850)
;endyr          = (1970 - 1850)
;For 1D time data
;startyr        = (1991 - 1850)*12
;endyr          = (2010 - 1850)*12 + 11
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


printVarSummary(crop)
print(dimsizes(month))

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
irrconv   = grain1dirr
ferconv   = grain1dfer
irfconv   = grain1dirf
lucconv   = grain1dluc


;.....Control......
crop4d        = reshape(crop,(/nyr,nmon,nlat,nlon/))
crop4d!2      = "lat"
crop4d&lat    = lat
cropannual    = dim_avg_n_Wrap(crop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarCoords_n(crop,cropannual,(/1,2/))
printVarSummary(cropannual)

cropnbp       = dim_avg_n_Wrap(crop4d(158:160,:,{30:},:),(/2,3/))
;cropnbp       = dim_avg_n_Wrap(crop4d(78:80,:,{30:},:),(/2,3/))
cropyravg     = dim_avg_n_Wrap(cropnbp,0)
print("2009-2011 NBP amplutide with crops = "+(dim_max_n_Wrap(cropyravg,0) - dim_min_n_Wrap(cropyravg,0)))

;.....Treatment.....

cropirr4d      = reshape(irrconv,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d, cropirr4d)
cropirrannual  = dim_avg_n_Wrap(cropirr4d(startyr:endyr,:,{30:},:), (/2,3/))        ;1990-2010
;copy_VarMeta(cropannual,cropirrannual)

cropfer4d      = reshape(ferconv,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,cropfer4d)
cropferannual  = dim_avg_n_Wrap(cropfer4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,cropferannual)

cropirf4d      = reshape(irfconv,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d, cropirf4d)
cropirfannual  = dim_avg_n_Wrap(cropirf4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,cropirfannual)

cropluc4d      = reshape(lucconv,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,cropluc4d)
croplucannual  = dim_avg_n_Wrap(cropluc4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,croplucannual)


nocrop4d      = reshape(nocrop,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,nocrop4d)
nocropannual  = dim_avg_n_Wrap(nocrop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,nocropannual)

nocropnpb     = dim_avg_n_Wrap(nocrop4d(158:160,:,{30:},:),(/2,3/))
;nocropnpb     = dim_avg_n_Wrap(nocrop4d(78:80,:,{30:},:),(/2,3/))
nocropyravg   = dim_avg_n_Wrap(nocropnpb,0)
print("2009-2011 NBP amplutide without crops = "+(dim_max_n_Wrap(nocropyravg,0) - dim_min_n_Wrap(nocropyravg,0)))


  grainCtimeUS     = dim_avg_n_Wrap(cropannual,0) 
  irrgrainCtimeUS  = dim_avg_n_Wrap(cropirrannual,0)        
  fergrainCtimeUS  = dim_avg_n_Wrap(cropferannual,0)
  irfgrainCtimeUS  = dim_avg_n_Wrap(cropirfannual,0)
  lucgrainCtimeUS  = dim_avg_n_Wrap(croplucannual,0)
  nograinCtimeUS  = dim_avg_n_Wrap(nocropannual,0)

  grainCtimevar     = dim_stddev_n_Wrap(cropannual,0) 
  irrgrainCtimevar  = dim_stddev_n_Wrap(cropirrannual,0)        
  fergrainCtimevar  = dim_stddev_n_Wrap(cropferannual,0)
  irfgrainCtimevar  = dim_stddev_n_Wrap(cropirfannual,0)
  lucgrainCtimevar  = dim_stddev_n_Wrap(croplucannual,0)
  nograinCtimevar   = dim_stddev_n_Wrap(nocropannual,0)


  printVarSummary(grainCtimeUS)


;.....Combined......
if (sensitivity .eq. "True") then

  psstr     = "CropSensitivitySims_"+var+"_"+avgyr

  USGrainC      = new((/4,nmon/),float)
  USGrainC!1    = "month"
  USGrainC&month= month
  printVarSummary(USGrainC)

  USGrainC(0,:) = (/grainCtimeUS/)
  USGrainC(2,:) = (/irrgrainCtimeUS/)
  USGrainC(1,:) = (/fergrainCtimeUS/)
  USGrainC(3,:) = (/lucgrainCtimeUS/)

else

  psstr     = "CropMinusNoCrop_"+var+"_"+avgyr

  USGrainC      = new((/2,nmon/),float)
  USGrainC!1    = "month"
  USGrainC&month= month
  printVarSummary(USGrainC)

  USGrainC(0,:) = (/grainCtimeUS/)
  USGrainC(1,:) = (/nograinCtimeUS/)

  nograinSD     = USGrainC
  nograinSD(0,:)= nograinCtimeUS + nograinCtimevar
  nograinSD(1,:)= nograinCtimeUS - nograinCtimevar

  grainSD       = USGrainC
  grainSD(0,:)  = grainCtimeUS + grainCtimevar
  grainSD(1,:)  = grainCtimeUS - grainCtimevar 

end if


;************* PLOTTING **************

; ***** CA only time series *****
res                        = True
if (sensitivity .eq. "True") then
  wks             = gsn_open_wks ("pdf", var+"_Sensitivity_AnnualCycle_NorthernHem_"+avgyr)
  res@xyExplicitLegendLabels = (/" CLM5",  " No Fertilization", " No Irrigation", " No Cropland Expansion"/)
  res@lgItemOrder            = (/3,2,1,0/)    ; reorders the legend labels
else
  wks             = gsn_open_wks ("pdf", var+"_GenericCrop_AnnualCycle_NorthernHem_"+avgyr)
  res@xyExplicitLegendLabels = (/" Active Crops", " Generic Crops"/)         ; create explicit labels
  res@lgItemOrder            = (/1,0/)    ; reorders the legend labels
end if

res@xyDashPattern          = 0
res@gsnMaximize            = True
res@gsnFrame               = False
res@tiXAxisString          = "Month"
res@tiYAxisString          = varln+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res@gsnYRefLine            = 0.0
res@gsnYRefLineDashPattern = 1
res@gsnYRefLineThicknessF  = 1.5
res@xyLineThicknessF       = 3
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"
res@pmLegendParallelPosF   = .14                 ; move units right; note: used 0.25 for nocrop
res@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res@pmLegendWidthF         = 0.075               ; Change width and
res@pmLegendHeightF        = 0.18                ; height of legend.
res@lgLabelFontHeightF     = .01                 ; label font height
res@tmXBLabels             = (/" Jan ", " Feb ", " Mar ", " Apr ", " May ", " Jun ", " Jul ", " Aug ", " Sep ", " Oct ", " Nov ", " Dec "/)

if (var .eq. "LAND_USE_FLUX") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 0.12
;  res@trYMaxF                = 0.1
end if
if (var .eq. "COL_FIRE_CLOSS") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 0.12
end if
if (var .eq. "NBP") then
  res@trYMinF                = -0.6                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 1.2
end if
if (var .eq. "GPP") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 5
end if
if (var .eq. "ER") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 5
;  res@trYMaxF                = 4
end if


if (sensitivity .eq. "True") then
  res@xyLineColors           = (/"purple4","darkorange3","turquoise4","gray40"/) 
  plot                 = gsn_csm_xy(wks,month,USGrainC,res)
;Note: Sensitivity plot isn't working correctly. Below line plots everything as 0
;  plot                 = gsn_csm_xy(wks,month,irrgrainCtimeUS,res)
else
  res@gsnXYFillColors  = "olivedrab"
  res@xyLineColor      = -1    ; makes the line transparent
  res@gsnXYFillOpacities = 0.2
  plot                 = gsn_csm_xy(wks,month,nograinSD,res)
  delete(res@gsnXYFillColors)
  delete(res@xyLineColor)

  res@gsnXYFillColors = "purple4"
  res@xyLineColor     = -1
  nextplot            = gsn_csm_xy(wks,month,grainSD,res)
  delete(res@gsnXYFillColors)
  delete(res@xyLineColor)

  res@xyLineColors           = (/"purple4","olivedrab"/)
  plotlines                 = gsn_csm_xy(wks,month,USGrainC,res)
end if


exit

