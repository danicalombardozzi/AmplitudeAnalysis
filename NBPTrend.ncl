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

  nocropdir          = "/glade/p/cesm/lmwg_dev/dll/CLM5GSWP3_NoCrop/SingleVarTimeFiles/"
  cropsim            = "clm50_r267_1deg_GSWP3V1_iso_hist_nocrop_transientfix"
  cropdata           =addfile(nocropdir+cropsim+".clm2.h0."+var+"."+simyrs+".nc","r")


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


;.....Control......
crop4d        = reshape(crop,(/nyr,nmon,nlat,nlon/))
crop4d!2      = "lat"
crop4d&lat    = lat
crop4d!3      = "lon"
crop4d&lon    = lon
cropannual    = dim_avg_n_Wrap(crop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarCoords_n(crop,cropannual,(/1,2/))
;printVarSummary(cropannual)

cropnbp       = dim_avg_n_Wrap(crop4d(158:160,:,{30:},:),(/2,3/))
;cropnbp       = dim_avg_n_Wrap(crop4d(78:80,:,{30:},:),(/2,3/))
cropyravg     = dim_avg_n_Wrap(cropnbp,0)
print("2009-2011 NBP amplutide with crops = "+(dim_max_n_Wrap(cropyravg,0) - dim_min_n_Wrap(cropyravg,0)))

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

cropTrendSD = dim_stddev_n_Wrap(cropAmpNorm,(/1,2/))
copy_VarMeta(cropTrend,cropTrendSD)
;printVarSummary(cropTrendSD)

;.....Treatment.....
nocrop4d      = reshape(nocrop,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,nocrop4d)
nocropannual  = dim_avg_n_Wrap(nocrop4d(startyr:endyr,:,{30:},:), (/2,3/))
;copy_VarMeta(cropannual,nocropannual)

nocropnpb     = dim_avg_n_Wrap(nocrop4d(158:160,:,{30:},:),(/2,3/))
;nocropnpb     = dim_avg_n_Wrap(nocrop4d(78:80,:,{30:},:),(/2,3/))
nocropyravg   = dim_avg_n_Wrap(nocropnpb,0)
print("2009-2011 NBP amplutide without crops = "+(dim_max_n_Wrap(nocropyravg,0) - dim_min_n_Wrap(nocropyravg,0)))

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

nocropTrendSD = dim_stddev_n_Wrap(nocropAmpNorm,(/1,2/))
copy_VarMeta(nocropTrend,nocropTrendSD)



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


;************* PLOTTING **************
res                        = True
wks             = gsn_open_wks ("pdf", var+"_GenericCrop_Timeseries_NorthernHem")
res@xyExplicitLegendLabels = (/" Active Crops", " Generic Crops"/)         ; create explicit labels
res@lgItemOrder            = (/1,0/)    ; reorders the legend labels

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
res@pmLegendParallelPosF   = .14                 ; move units right; note: used 0.25 for nocrop
res@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res@pmLegendWidthF         = 0.075               ; Change width and
res@pmLegendHeightF        = 0.18                ; height of legend.
res@lgLabelFontHeightF     = .01                 ; label font height

if (var .eq. "NBP") then
  res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
  res@trYMaxF                = 1.2
end if


;  res@gsnXYFillColors  = "olivedrab"
;  res@xyLineColor      = -1    ; makes the line transparent
;  res@gsnXYFillOpacities = 0.2
;  plot                 = gsn_csm_xy(wks,years,nograinSD,res)
;  delete(res@gsnXYFillColors)
;  delete(res@xyLineColor)
;
;  res@gsnXYFillColors = "purple4"
;  res@xyLineColor     = -1
;  nextplot            = gsn_csm_xy(wks,years,grainSD,res)
;  delete(res@gsnXYFillColors)
;  delete(res@xyLineColor)

  res@xyLineColors           = (/"purple4","olivedrab"/)
  plotlines                 = gsn_csm_xy(wks,years,USGrainC,res)

























