load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


simyrs             = "185001-201412"
var                = "CO2"

datadir            = "/glade/p/cesm/lmwg_dev/dll/"
Mod1dir            = "CESM2_Coupled_NoCrop/"
print("data directory = "+datadir)
sim                = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.001"
data               = addfile(datadir+Mod1dir+sim+".cam.h0."+var+"."+simyrs+".nc","r")

;.......
sim2               = "b40.20th.1deg.coup.001"
data2              = addfile(datadir+Mod1dir+sim2+".cam2.h0."+var+".185001-200512.nc","r")

;.......
subdir             = "/atm/proc/tseries/month_1/"
sim3               = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.002_NoCropSpin_Transient1970-2014"
data3              = addfile(datadir+Mod1dir+subdir+sim3+".cam.h0."+var+".197001-201412.nc","r")

;.......
Mod2dir            = "CESM2_Coupled_NoFert/"
sim4               = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.002_NoFert_Transient1970-2014"
data4              = addfile(dir+Mod1dir+subdir+sim4+".cam.h0."+var+".197001-201412.nc","r")


;....... Area ......
datadir        = "/glade/collections/cdg/data/CMIP6/CMIP/NCAR/"
model          = "CESM2"
simtype        = "historical"
varsn          = "gn"
latest         = "latest"
sims           = "r1i1p1f1"

areadir    = (datadir+model+"/"+simtype+"/"+sims(0)+"/fx/")
areavar    = "areacella"
fracvar    = "sftlf"

areadata   = addfile(areadir+areavar+"/"+varsn+"/"+latest+"/areacella_fx_CESM2_historical_r1i1p1f1_gn.nc","r")
fracdata   = addfile(areadir+fracvar+"/"+varsn+"/"+latest+"/sftlf_fx_CESM2_historical_r1i1p1f1_gn.nc","r")

area       = areadata->$areavar$
landfrac   = fracdata->$fracvar$



;------- VARIABLES -------------
lat            = data->lat
lon            = data->lon
nlat           = dimsizes(lat)
nlon           = dimsizes(lon)
yearsCESM2     = ispan(1850,2014,1)
yearsCESM1     = ispan(1850,2005,1)
yearsnocrop    = ispan(1970,2014,1)
month          = ispan(1,12,1)

startyr        = (1995 - 1850)
endyr          = (2005 - 1850)
startyrnocrop  = (1995 - 1970)
endyrnocrop    = (2005 - 1970)
;print(startyr)
;print(endyr)

co2            = data->$var$(:,31,:,:)
cesm1co2       = data2->$var$(:,25,:,:)
nocropco2      = data3->$var$(:,31,:,:)
nofertco2      = data4->$var$(:,31,:,:)

printVarSummary(co2)
printVarSummary(cesm1co2)
printVarSummary(nocropco2)
printVarSummary(nofertco2)

exit

;------------------------------

nmon           =  12
ntimCESM2      =  dimsizes(co2(:,0,0))
nyrCESM2       =  ntimCESM2/nmon
ntimCESM1      =  dimsizes(cesm1co2(:,0,0))
nyrCESM1       =  ntimCESM1/nmon
ntimnocrop     =  dimsizes(nocropco2(:,0,0))
nyrnocrop      =  ntimnocrop/nmon
;print(nyrCESM2)
;print(nyrCESM1)
;print(nyrnocrop)

if (var .eq. "CO2") then
  varln     = "CO~B~2~N~ "
  units     = " (ppm)"
  convert   = 1.0e6 * 28.966 / 44.0 
end if

datastr   = varln+units

co2       = co2*convert
cesm1co2  = cesm1co2*convert
nocropco2 = nocropco2*convert


;--------CESM2-----------
co2surf4d       = reshape(co2,(/nyrCESM2,nmon,nlat,nlon/))
co2surf4d!0     = "yearsCESM2"
co2surf4d!1     = "month"
co2surf4d!2     = "lat"
co2surf4d&lat   = lat
co2surf4d!3     = "lon"
co2surf4d&lon   = lon

;....area weighting
areamon         = conform_dims(dimsizes(co2surf4d(startyr:endyr,:,{30:},:)),area({30:},:), (/2,3/))
co2annualyrs    = dim_sum_n_Wrap(co2surf4d(startyr:endyr,:,{30:},:)*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;co2annualyrs    = dim_avg_n_Wrap(co2surf4d(startyr:endyr,:,{30:},:),(/2,3/))

;...Calculating average detrended 10-year annual cycle....
co2detrend      = dtrend(co2annualyrs, False)
co2annual       = dim_avg_n_Wrap(co2detrend,0)

co2annualSD     = dim_stddev_n_Wrap(co2detrend,0)
co2SD      = new((/2,nmon/),float)
co2SD!1    = "month"
co2SD&month= month
co2SD(0,:) = co2annual+co2annualSD
co2SD(1,:) = co2annual-co2annualSD

print(startyr+1850 + "-"+(endyr+1850)+ "  CO2 amplitude in CESM2 = "+(dim_max_n_Wrap(co2annual,0) - dim_min_n_Wrap(co2annual,0)))

;...Calculating each year's amplitude to generate time series ....
co2Min     = dim_min_n_Wrap(co2surf4d(:,:,{30:},:),1)
co2Max     = dim_max_n_Wrap(co2surf4d(:,:,{30:},:),1)
co2Amp     = (co2Max - co2Min)
copy_VarMeta(co2Max,co2Amp)
;printVarSummary(co2Amp)

co2amp1850 = co2Amp(0,:,:)
co2ampConf = conform_dims(dimsizes(co2Amp),co2amp1850,(/1,2/))

co2ampNorm = co2Amp - co2ampConf

;...area weighting CO2 trend
area3d      = conform_dims(dimsizes(co2ampNorm),area({30:},:), (/1,2/))
co2Trend   = dim_sum_n_Wrap(co2Amp*area3d,(/1,2/))/dim_sum_n_Wrap(area3d,(/1,2/))
;co2Trend   = dim_sum_n_Wrap(co2ampNorm*area3d,(/1,2/))/dim_sum_n_Wrap(area3d,(/1,2/))
;co2Trend   = dim_avg_n_Wrap(co2ampNorm, (/1,2/))
co2Trend!0 = "yearsCESM2"
co2Trend&yearsCESM2 = yearsCESM2
;printVarSummary(co2Trend)
print("CO2 Amplitude in  1970 = "+co2Trend(120) +", "+ (endyr+1850) +" = "+co2Trend(endyr) + ", and "+ (nyrCESM2+1850)+" = "+co2Trend(nyrCESM2-1))

;....maps.....
co2MapMin  = dim_min_n_Wrap(dim_avg_n_Wrap(co2surf4d(startyr:endyr,:,:,:),0),0)
co2MapMax  = dim_max_n_Wrap(dim_avg_n_Wrap(co2surf4d(startyr:endyr,:,:,:),0),0)
co2map     = co2MapMax - co2MapMin
co2map!0   = "lat"
co2map!1   = "lon"
co2map&lat = lat
co2map&lon = lon


;--------CESM1-----------
cesm1co2surf4d       = reshape(cesm1co2,(/nyrCESM1,nmon,nlat,nlon/))
cesm1co2surf4d!2     = "lat"
cesm1co2surf4d&lat   = lat
cesm1co2surf4d!3     = "lon"
cesm1co2surf4d&lon   = lon

cesm1co2annualyrs    = dim_sum_n_Wrap(cesm1co2surf4d(startyr:endyr,:,{30:},:)*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;cesm1co2annualyrs    = dim_avg_n_Wrap(cesm1co2surf4d(startyr:endyr,:,{30:},:),(/2,3/))
cesm1co2detrend       = dtrend(cesm1co2annualyrs, False)
cesm1co2annual        = dim_avg_n_Wrap(cesm1co2detrend,0)

cesm1co2annualSD     = dim_stddev_n_Wrap(cesm1co2detrend,0)
;printVarSummary(cesm1co2annualSD)
cesm1co2SD      = new((/2,nmon/),float)
cesm1co2SD!1    = "month"
cesm1co2SD&month= month
cesm1co2SD(0,:) = cesm1co2annual+cesm1co2annualSD
cesm1co2SD(1,:) = cesm1co2annual-cesm1co2annualSD

print(startyr+1850 + "-"+(endyr+1850)+ " CO2 amplitude in CESM1 = "+(dim_max_n_Wrap(cesm1co2annual,0) - dim_min_n_Wrap(cesm1co2annual,0)))

;...Calculating each year's amplitude to generate time series ....
cesm1co2Min     = dim_min_n_Wrap(cesm1co2surf4d(:,:,{30:},:),1)
cesm1co2Max     = dim_max_n_Wrap(cesm1co2surf4d(:,:,{30:},:),1)
cesm1co2Amp     = (cesm1co2Max - cesm1co2Min)
copy_VarMeta(cesm1co2Max,cesm1co2Amp)
;printVarSummary(cesm1co2Amp)

cesm1co2Trend   = dim_sum_n_Wrap(cesm1co2Amp*area3d(:155,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(:155,:,:),(/1,2/))
;Normalized for 1850
;cesm1co2amp1850 = cesm1co2Amp(0,:,:)
;cesm1co2ampConf = conform_dims(dimsizes(cesm1co2Amp),cesm1co2amp1850,(/1,2/))
;cesm1co2Trend   = dim_sum_n_Wrap(cesm1co2ampNorm*area3d(:155,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(:155,:,:),(/1,2/))
;cesm1co2Trend   = dim_avg_n_Wrap(cesm1co2ampNorm, (/1,2/))
;cesm1co2ampNorm = cesm1co2Amp - cesm1co2ampConf
cesm1co2Trend!0 = "yearsCESM1"
cesm1co2Trend&yearsCESM1 = yearsCESM1
;printVarSummary(cesm1co2Trend)
print("CO2 Amp diff 1970 = "+cesm1co2Trend(120) +" and "+ (endyr+1850) +" = "+cesm1co2Trend(endyr))

cesm1co2MapMin  = dim_min_n_Wrap(dim_avg_n_Wrap(cesm1co2surf4d(startyr:endyr,:,:,:),0),0)
cesm1co2MapMax  = dim_max_n_Wrap(dim_avg_n_Wrap(cesm1co2surf4d(startyr:endyr,:,:,:),0),0)
cesm1co2map     = cesm1co2MapMax - cesm1co2MapMin
cesm1co2map!0   = "lat"
cesm1co2map!1   = "lon"
cesm1co2map&lat = lat
cesm1co2map&lon = lon

;--------NoCrop-----------
nocropco2surf4d       = reshape(nocropco2,(/nyrnocrop,nmon,nlat,nlon/))
nocropco2surf4d!2     = "lat"
nocropco2surf4d&lat   = lat
nocropco2surf4d!3     = "lon"
nocropco2surf4d&lon   = lon

nocropco2annualyrs    = dim_sum_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,{30:},:)*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;nocropco2annualyrs    = dim_avg_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,{30:},:),(/2,3/))
nocropco2detrend      = dtrend(nocropco2annualyrs,False)
nocropco2annual       = dim_avg_n_Wrap(nocropco2detrend,0)

nocropco2annualSD     = dim_stddev_n_Wrap(nocropco2detrend,0)
nocropco2SD      = new((/2,nmon/),float)
nocropco2SD!1    = "month"
nocropco2SD&month= month
nocropco2SD(0,:) = nocropco2annual+nocropco2annualSD
nocropco2SD(1,:) = nocropco2annual-nocropco2annualSD

print(startyrnocrop+1970 + "-"+(endyrnocrop+1970)+ " CO2 amplitude in CESM2nocrop = "+(dim_max_n_Wrap(nocropco2annual,0) - dim_min_n_Wrap(nocropco2annual,0)))

;printVarSummary(nocropco2detrend)
;print(nocropco2detrend)
;printVarSummary(nocropco2annual)
;print(nocropco2annual)
;printVarSummary(nocropco2annualSD)
;print(nocropco2annualSD)

nocropco2Min     = dim_min_n_Wrap(nocropco2surf4d(:,:,{30:},:),1)
nocropco2Max     = dim_max_n_Wrap(nocropco2surf4d(:,:,{30:},:),1)
nocropco2Amp     = (nocropco2Max - nocropco2Min)
copy_VarMeta(nocropco2Max,nocropco2Amp)
;printVarSummary(nocropco2Amp)

nocropco2Trend   = dim_sum_n_Wrap(nocropco2Amp*area3d(120:,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(120:,:,:),(/1,2/))
;nocropco2ampNorm = nocropco2Amp - nocropco2ampConf
;nocropco2ampNorm = nocropco2Amp - co2ampConf(120:,:,:) 
;nocropco2amp1850 = nocropco2Amp(0,:,:)
;nocropco2ampConf = conform_dims(dimsizes(nocropco2Amp),nocropco2amp1850,(/1,2/))
;nocropco2Trend   = dim_sum_n_Wrap(nocropco2ampNorm*area3d(120:,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(120:,:,:),(/1,2/))
;nocropco2Trend   = dim_avg_n_Wrap(nocropco2ampNorm, (/1,2/))
nocropco2Trend!0 = "yearsnocrop"
nocropco2Trend&yearsnocrop = yearsnocrop
;printVarSummary(nocropco2Trend)
print("CO2 Amp diff 1970 = "+nocropco2Trend(0) +", "+ (endyrnocrop+1970) +" = "+nocropco2Trend(endyrnocrop)+", and "+(nyrnocrop+1970)+" = "+nocropco2Trend(nyrnocrop-1))

nocropco2MapMin  = dim_min_n_Wrap(dim_avg_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,:,:),0),0)
nocropco2MapMax  = dim_max_n_Wrap(dim_avg_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,:,:),0),0)
nocropco2map     = nocropco2MapMax - nocropco2MapMin
nocropco2map!0   = "lat"
nocropco2map!1   = "lon"
nocropco2map&lat = lat
nocropco2map&lon = lon


;--------Stats---------

co2reg          = regline(yearsCESM2(120:161),co2Trend(120:161))
cesm1co2reg     = regline(yearsCESM1(120:),cesm1co2Trend(120:))
nocropco2reg    = regline(yearsnocrop(:41),nocropco2Trend(:41))

print(co2reg)
print(cesm1co2reg)
print(nocropco2reg)
;note: slope is the number printed: (0) slope


;------- Compiling All ---------
;...Difference Maps.....
landmsk    = where(landfrac.gt.0,1,0)
cesm1diffmap     = (cesm1co2map - co2map)*landmsk
nocropdiffmap    = (nocropco2map - co2map)*landmsk
copy_VarMeta(co2map,cesm1diffmap)
copy_VarMeta(co2map,nocropdiffmap)
printMinMax(cesm1diffmap,0)
printMinMax(nocropdiffmap,0)

;.... land mask for abs value maps
co2mapmsk        = co2map * landmsk
cesm1mapmsk      = cesm1co2map * landmsk
nocropmapmsk     = nocropco2map * landmsk
copy_VarMeta(co2map, co2mapmsk)
copy_VarMeta(co2map, cesm1mapmsk)
copy_VarMeta(co2map, nocropmapmsk)


;...This only works when all are the same length...
  CO2Trend      = new((/3,nyrCESM2/),float)
  CO2Trend!1    = "yearsCESM2"
  CO2Trend&yearsCESM2= yearsCESM2

  co2dummy      = new(dimsizes(co2Trend),float) 

  CO2Trend(0,:) = (/co2dummy/)
  CO2Trend(1,:) = (/co2Trend/)
  CO2Trend(2,:) = (/co2dummy/)

  CO2Cycle      = new((/3,nmon/),float)
  CO2Cycle(0,:) = (/co2annual/)
  CO2Cycle(1,:) = (/cesm1co2annual/)
  CO2Cycle(2,:) = (/nocropco2annual/)


;************* PLOTTING **************
print("Plotting Data")
;............Timeseries...............
res                        = True
wks                        = gsn_open_wks ("pdf", var+"_CESM_Timeseries_NorthernHem")

res@xyDashPattern          = 0
res@gsnMaximize            = True
res@gsnFrame               = False
res@tiXAxisString          = "Year"
res@tiYAxisString          = "~F33~D ~F21~ CO~B~2~N~ Amplitude"+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res@gsnYRefLine            = 0.0
res@gsnYRefLineDashPattern = 1
res@gsnYRefLineThicknessF  = 1.5
res@xyLineThicknessF       = 3

;For normalized data
;res@trYMinF                = -5                ; use this and next line to change timescale that is graphed
;res@trYMaxF                = 10
;For absolute data
res@trYMinF                = 6                ; use this and next line to change timescale that is graphed
res@trYMaxF                = 18
res@trXMinF                = 1850                ; use this and next line to change timescale that is graphed
res@trXMaxF                = 2015


res@xyExplicitLegendLabels = (/"CESM1","CESM2","CESM2 generic crop"/)
res@lgItemOrder            = (/ 2,1,0 /)  
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"
res@lgPerimOn              = False      ; No legend perimeter.
res@pmLegendParallelPosF   = .20                 ; move units right; note: used 0.25 for nocrop
res@pmLegendOrthogonalPosF = -0.20       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res@pmLegendWidthF         = 0.075               ; Change width and
res@pmLegendHeightF        = 0.10                ; height of legend.
res@lgLabelFontHeightF     = .015                ; label font height

;plotlines                 = gsn_csm_xy(wks,years,CO2Trend,res)
res@xyLineColors          = (/"sienna3", "slateblue3", "steelblue3"/)
;res@xyLineColors          = (/"black", "red", "blue"/)
;plotlines0                = gsn_csm_xy(wks,yearsCESM2,co2Trend,res)
plotlines0                = gsn_csm_xy(wks,yearsCESM2,CO2Trend,res)
delete(res@xyLineColors)

res@pmLegendDisplayMode   = "Never"
res@xyLineColor           = (/"sienna3"/)
plotlines1                = gsn_csm_xy(wks,yearsCESM1,cesm1co2Trend,res)
res@xyLineColor           = (/"steelblue3"/)
plotlines2                = gsn_csm_xy(wks,yearsnocrop,nocropco2Trend,res)



;...........AnnualCycle.............

res2                      = True
wks2                      = gsn_open_wks ("pdf", var+"_CESM_AnnualCycle_NorthernHem")

res2@xyDashPattern          = 0
res2@gsnMaximize            = True
res2@gsnFrame               = False
res2@tiXAxisString          = "Month"
res2@tiYAxisString          = varln+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res2@gsnYRefLine            = 0.0
res2@gsnYRefLineDashPattern = 1
res2@gsnYRefLineThicknessF  = 1.5
res2@xyLineThicknessF       = 3
res2@tmXBLabels             = (/" Jan ", " Feb ", " Mar ", " Apr ", " May ", " Jun ", " Jul ", " Aug ", " Sep ", " Oct ", " Nov ", " Dec "/)


res2@trYMinF                = -10                ; use this and next line to change timescale that is graphed
res2@trYMaxF                = 10

res2@xyExplicitLegendLabels = (/"CESM2","CESM1","CESM2 generic crop"/) 
res2@lgItemOrder            = (/2,1,0/)    ; reorders the legend labels

res2@gsnXYFillColors  = "slateblue3"
res2@xyLineColor      = -1    ; makes the line transparent
res2@gsnXYFillOpacities = 0.2
plot                 = gsn_csm_xy(wks2,month,co2SD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

res2@gsnXYFillColors = "sienna3"
res2@xyLineColor     = -1
nextplot            = gsn_csm_xy(wks2,month,cesm1co2SD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

res2@gsnXYFillColors = "steelblue3"
res2@xyLineColor     = -1
nextplot            = gsn_csm_xy(wks2,month,nocropco2SD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

res2@pmLegendParallelPosF   = .10                 ; move units right; note: used 0.25 for nocrop
res2@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res2@pmLegendWidthF         = 0.075               ; Change width and
res2@pmLegendHeightF        = 0.10                ; height of legend.
res2@lgLabelFontHeightF     = .015                 ; label font height

res2@xyLineColors          = (/"slateblue3","sienna3", "steelblue3"/)
plotlines2                  = gsn_csm_xy(wks2,month,CO2Cycle,res2)


exit
;........Maps..........

  wks3    =  gsn_open_wks( "pdf", var+"_CESM_Maps")

  gsn_define_colormap(wks3, "BlWhRe")

  res3                       = True             ; turn on plotting options
  res3@lbLabelBarOn          = False
  res3@gsnSpreadColors       = True             ; spans all colors in colormap
  res3@cnFillOn              = True             ; turn on color fill
  res3@cnLinesOn             = False            ; turn off contour lines
  res3@cnLineLabelsOn        = False            ; turn off contour line labels

  res3@mpProjection          = "robinson"       ; Robinson grid projection
  res3@gsnDraw               = False
  res3@gsnFrame              = False
  res3@lbAutoManage          = False
  res3@lbLabelFontHeightF    = 0.015
  res3@txFontHeightF         = 0.025
;  res3@cnRasterModeOn        = True

;  res3@mpFillDrawOrder       = "PreDraw"         ; Draw map fill last

  plots                      = new(2,graphic)
  res3@cnLevelSelectionMode  = "ExplicitLevels"   ;
  res3@cnLevels              = ((/-15,-12, -9, -6,-3,-1,1,3,6,9,12,15/))
  res3@mpLimitMode           = "LatLon"
  res3@mpMinLatF             = -60

  res3@gsnLeftString          = ""
  res3@gsnRightString         = ""
  res3@gsnCenterString        = ""

  res3@tiMainString          = "CESM1"
  plots(0)                   = gsn_csm_contour_map(wks3,cesm1diffmap,res3)

  res3@tiMainString          = "CESM2 Generic Crop"
  plots(1)                   = gsn_csm_contour_map(wks3,nocropdiffmap,res3)

  pres3                      = True
  pres3@gsnFrame             = False
  pres3@lbTitleString        = "~F33~D ~F21~ CO~B~2~N~ Amplitude (ppm)"
  pres3@lbTitlePosition      = "Bottom"
  pres3@lbTitleFontHeightF   = 0.015
  pres3@lbLabelFontHeightF   = 0.01
  pres3@gsnPanelLabelBar     = True
  pres3@gsnPanelBottom       = 0.05
  pres3@gsnPanelYWhiteSpacePercent = 5

  gsn_panel(wks3,plots,(/2,1/),pres3)
  frame(wks3)



;.....absolute values........
  wks4    =  gsn_open_wks( "pdf", var+"_CESM_Maps_AbsVal")

  gsn_define_colormap(wks4, "WhViBlGrYeOrRe")

  res4                       = True             ; turn on plotting options
  res4@lbLabelBarOn          = False
  res4@gsnSpreadColors       = True             ; spans all colors in colormap
  res4@cnFillOn              = True             ; turn on color fill
  res4@cnLinesOn             = False            ; turn off contour lines
  res4@cnLineLabelsOn        = False            ; turn off contour line labels

  res4@mpProjection          = "robinson"       ; Robinson grid projection
  res4@gsnDraw               = False
  res4@gsnFrame              = False
  res4@lbAutoManage          = False
  res4@lbLabelFontHeightF    = 0.015
  res4@txFontHeightF         = 0.025

  plots2                     = new(3,graphic)
;  res4@cnLevelSelectionMode  = "ExplicitLevels"   ;
;  res4@cnLevels              = ((/-15,-12, -9, -6,-3,-1,1,3,6,9,12,15/))
  res4@mpLimitMode           = "LatLon"
  res4@mpMinLatF              = -60
  
  res4@gsnLeftString          = ""
  res4@gsnRightString         = ""
  res4@gsnCenterString        = ""
  
  res4@tiMainString          = "CESM2"
  plots2(0)                   = gsn_csm_contour_map(wks4,co2mapmsk,res4)

  res4@tiMainString          = "CESM1"
  plots2(1)                   = gsn_csm_contour_map(wks4,cesm1mapmsk,res4)
  
  res4@tiMainString          = "CESM2 Generic Crop"
  plots2(2)                   = gsn_csm_contour_map(wks4,nocropmapmsk,res4)
  
  pres4                      = True
  pres4@gsnFrame             = False
  pres4@lbTitleString        = " CO~B~2~N~ Amplitude (ppm)"
  pres4@lbTitlePosition      = "Bottom"
  pres4@lbTitleFontHeightF   = 0.015
  pres4@lbLabelFontHeightF   = 0.01
  pres4@gsnPanelLabelBar     = True
  pres4@gsnPanelBottom       = 0.05
  pres4@gsnPanelYWhiteSpacePercent = 5

  gsn_panel(wks4,plots2,(/3,1/),pres4)
  frame(wks4)





