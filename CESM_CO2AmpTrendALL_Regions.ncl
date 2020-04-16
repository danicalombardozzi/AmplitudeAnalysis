load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


simyrs             = "185001-201412"
var                = "CO2"

datadir            = "/glade/p/cesm/lmwg_dev/dll/CESM2_Coupled_NoCrop/"
print("data directory = "+datadir)
sim                = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.001"
data               = addfile(datadir+sim+".cam.h0."+var+"."+simyrs+".nc","r")

;.......
sim2               = "b40.20th.1deg.coup.001"
data2              = addfile(datadir+sim2+".cam2.h0."+var+".185001-200512.nc","r")

;.......
subdir             = "/atm/proc/tseries/month_1/"
sim3               = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.002_NoCropSpin_Transient1970-2014"
data3              = addfile(datadir+subdir+sim3+".cam.h0."+var+".197001-201412.nc","r")

;...... obs .....
obsdir             = "/glade/p/cesm/lmwg_dev/oleson/ILAMB/ILAMB_all/DATA/co2/NOAA.GMD/"
obsfile            = "co2.nc"
obsdata            = addfile(obsdir+obsfile, "r")


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
;yearsobs       = ispan(1968,2012,1)
yearsobs       = ispan(1972,2012,1)
month          = ispan(1,12,1)

startyr        = (1995 - 1850)
endyr          = (2005 - 1850)
startyrnocrop  = (1995 - 1970)
endyrnocrop    = (2005 - 1970)
startyrobs     = (1995 - 1968)
endyrobs       = (2005 - 1968)
;print(startyr)
;print(endyr)

co2            = data->$var$(:,31,:,:)
cesm1co2       = data2->$var$(:,25,:,:)
nocropco2      = data3->$var$(:,31,:,:)

;printVarSummary(co2)
;printVarSummary(cesm1co2)
;printVarSummary(nocropco2)


obsco2         = obsdata->co2
printVarSummary(obsco2)

;.... adding missing ML data.....
mldir    = "/glade/p/cesm/lmwg_dev/oleson/ILAMB/ILAMB_all/DATA/co2/MAUNA.LOA/"
mlfile   = "co2_1959-2013.nc"
mldata   = addfile(mldir+mlfile,"r")

mlco2    = mldata->co2
obsco2(0:108,43) = mlco2(120:228)


;------------------------------

nmon           =  12
ntimCESM2      =  dimsizes(co2(:,0,0))
nyrCESM2       =  ntimCESM2/nmon
ntimCESM1      =  dimsizes(cesm1co2(:,0,0))
nyrCESM1       =  ntimCESM1/nmon
ntimnocrop     =  dimsizes(nocropco2(:,0,0))
nyrnocrop      =  ntimnocrop/nmon
ndatobs        = dimsizes(obsco2(0,:))
ntimobs        = dimsizes(obsco2(:,0))
nyrobs         = ntimobs/nmon
print(nyrCESM2)
print(nyrCESM1)
print(nyrnocrop)

if (var .eq. "CO2") then
  varln     = "CO~B~2~N~ "
  units     = " (ppm)"
  convert   = 1.0e6 * 28.966 / 44.0 
end if

datastr   = varln+units

co2       = co2*convert
cesm1co2  = cesm1co2*convert
nocropco2 = nocropco2*convert

co2surf4d       = reshape(co2,(/nyrCESM2,nmon,nlat,nlon/))
co2surf4d!0     = "yearsCESM2"
co2surf4d!1     = "month"
co2surf4d!2     = "lat"
co2surf4d&lat   = lat
co2surf4d!3     = "lon"
co2surf4d&lon   = lon

cesm1co2surf4d       = reshape(cesm1co2,(/nyrCESM1,nmon,nlat,nlon/))
cesm1co2surf4d!0     = "yearsCESM1"
cesm1co2surf4d!1     = "month"
cesm1co2surf4d!2     = "lat"
cesm1co2surf4d&lat   = lat
cesm1co2surf4d!3     = "lon"
cesm1co2surf4d&lon   = lon

nocropco2surf4d       = reshape(nocropco2,(/nyrnocrop,nmon,nlat,nlon/))
nocropco2surf4d!0     = "yearsnocrop"
nocropco2surf4d!1     = "month"
nocropco2surf4d!2     = "lat"
nocropco2surf4d&lat   = lat
nocropco2surf4d!3     = "lon"
nocropco2surf4d&lon   = lon

obsco2yr       = reshape(obsco2,(/nyrobs,nmon,ndatobs/))


;------- Regions --------
;ML: 19.5N, 155.6W
;Barrow: 71.3N, 156.6W
;NH: 30N (30:90,0:359) --> does not work

location       = (/"Mauna_Loa","Barrow"/)
Sbound         = (/19.5,71.3/)
Nbound         = (/19.5,71.3/)
Wbound         = (/204.4,203.4/)
Ebound         = (/204.4,203.4/)

obsind         = (/43 ,12/)                 ;index points for ML and Barrow in obs data

nsites = dimsizes(location)

do i = 0,nsites-1
print(location(i))

;--------CESM2-----------
print("CESM2")
;....area weighting
areamon         = conform_dims(dimsizes(co2surf4d(startyr:endyr,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)})),area({Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}), (/2,3/))
co2annualyrs    = dim_sum_n_Wrap(co2surf4d(startyr:endyr,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)})*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;co2annualyrs    = dim_avg_n_Wrap(co2surf4d(startyr:endyr,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),(/2,3/))

;...Calculating average 10-year annual cycle....
co2detrend      = dtrend(co2annualyrs, False)
co2annual       = dim_avg_n_Wrap(co2detrend,0)
;printing 1995-2005 amplitude
print(startyr+1850 + "-"+(endyr+1850)+ "  CO2 amplitude in CESM2 = "+(dim_max_n_Wrap(co2annual,0) - dim_min_n_Wrap(co2annual,0)))

co2annualSD     = dim_stddev_n_Wrap(co2detrend,0)
co2SD      = new((/2,nmon/),float)
co2SD!1    = "month"
co2SD&month= month
co2SD(0,:) = co2annual+co2annualSD
co2SD(1,:) = co2annual-co2annualSD

;...Calculating each year's amplitude to generate time series ....
co2Min     = dim_min_n_Wrap(co2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
co2Max     = dim_max_n_Wrap(co2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
co2Amp     = (co2Max - co2Min)
copy_VarMeta(co2Max,co2Amp)
;printVarSummary(co2Amp)

;...area weighting CO2 trend
area3d      = conform_dims(dimsizes(co2Amp),area({Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}), (/1,2/))
;Raw values, area-weighted
co2Trend   = dim_sum_n_Wrap(co2Amp*area3d,(/1,2/))/dim_sum_n_Wrap(area3d,(/1,2/))
;Normalized for 1850
;co2amp1850 = co2Amp(0,:,:)
;co2ampConf = conform_dims(dimsizes(co2Amp),co2amp1850,(/1,2/))
;co2ampNorm = co2Amp - co2ampConf
;co2Trend   = dim_sum_n_Wrap(co2ampNorm*area3d,(/1,2/))/dim_sum_n_Wrap(area3d,(/1,2/))
;Not area-weighted
;co2Trend   = dim_avg_n_Wrap(co2ampNorm, (/1,2/))
co2Trend!0 = "yearsCESM2"
co2Trend&yearsCESM2 = yearsCESM2
print("CO2 Amplitude in  1970 = "+co2Trend(120) +", "+ (endyr+1850) +" = "+co2Trend(endyr) + ", and "+ (nyrCESM2+1850)+" = "+co2Trend(nyrCESM2-1))


;--------CESM1-----------
print("CESM1")
cesm1co2annualyrs    = dim_sum_n_Wrap(cesm1co2surf4d(startyr:endyr,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)})*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;cesm1co2annualyrs    = dim_avg_n_Wrap(cesm1co2surf4d(startyr:endyr,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),(/2,3/))
cesm1co2detrend       = dtrend(cesm1co2annualyrs, False)
cesm1co2annual       = dim_avg_n_Wrap(cesm1co2detrend,0)
print(startyr+1850 + "-"+(endyr+1850)+ " CO2 amplitude in CESM1 = "+(dim_max_n_Wrap(cesm1co2annual,0) - dim_min_n_Wrap(cesm1co2annual,0)))

cesm1co2annualSD     = dim_stddev_n_Wrap(cesm1co2detrend,0)
cesm1co2SD      = new((/2,nmon/),float)
cesm1co2SD!1    = "month"
cesm1co2SD&month= month
cesm1co2SD(0,:) = cesm1co2annual+cesm1co2annualSD
cesm1co2SD(1,:) = cesm1co2annual-cesm1co2annualSD

;...Calculating each year's amplitude to generate time series ....
cesm1co2Min     = dim_min_n_Wrap(cesm1co2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
cesm1co2Max     = dim_max_n_Wrap(cesm1co2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
cesm1co2Amp     = (cesm1co2Max - cesm1co2Min)
copy_VarMeta(co2Max,cesm1co2Amp)

;...area weighting CO2 trend...
cesm1co2Trend   = dim_sum_n_Wrap(cesm1co2Amp*area3d(:155,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(:155,:,:),(/1,2/))
;Normalized for 1850
;cesm1co2amp1850 = cesm1co2Amp(0,:,:)
;cesm1co2ampConf = conform_dims(dimsizes(cesm1co2Amp),cesm1co2amp1850,(/1,2/))
;cesm1co2ampNorm = cesm1co2Amp - cesm1co2ampConf
;cesm1co2Trend   = dim_sum_n_Wrap(cesm1co2ampNorm*area3d(:155,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(:155,:,:),(/1,2/))
;Not area-weighted
;cesm1co2Trend   = dim_avg_n_Wrap(cesm1co2ampNorm, (/1,2/))
cesm1co2Trend!0 = "yearsCESM1"
cesm1co2Trend&yearsCESM1 = yearsCESM1
print("CO2 Amp diff 1970 = "+cesm1co2Trend(120) +" and "+ (endyr+1850) +" = "+cesm1co2Trend(endyr))

;--------NoCrop-----------
print("CESM2 Generic Crop")
nocropco2annualyrs    = dim_sum_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)})*areamon,(/2,3/))/dim_sum_n_Wrap(areamon,(/2,3/))
;nocropco2annualyrs    = dim_avg_n_Wrap(nocropco2surf4d(startyrnocrop:endyrnocrop,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),(/2,3/))
nocropco2detrend      = dtrend(nocropco2annualyrs,False)
nocropco2annual       = dim_avg_n_Wrap(nocropco2detrend,0)
print(startyrnocrop+1970 + "-"+(endyrnocrop+1970)+ " CO2 amplitude in CESM2nocrop = "+(dim_max_n_Wrap(nocropco2annual,0) - dim_min_n_Wrap(nocropco2annual,0)))

nocropco2annualSD     = dim_stddev_n_Wrap(nocropco2detrend,0)
nocropco2SD      = new((/2,nmon/),float)
nocropco2SD!1    = "month"
nocropco2SD&month= month
nocropco2SD(0,:) = nocropco2annual+nocropco2annualSD
nocropco2SD(1,:) = nocropco2annual-nocropco2annualSD

;...Calculating each year's amplitude to generate time series ....
nocropco2Min     = dim_min_n_Wrap(nocropco2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
nocropco2Max     = dim_max_n_Wrap(nocropco2surf4d(:,:,{Sbound(i):Nbound(i)},{Ebound(i):Wbound(i)}),1)
nocropco2Amp     = (nocropco2Max - nocropco2Min)
copy_VarMeta(co2Max,nocropco2Amp)

;...area weighting CO2 trend...
nocropco2Trend   = dim_sum_n_Wrap(nocropco2Amp*area3d(120:,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(120:,:,:),(/1,2/))
;Normalized for 1850
;nocropco2amp1850 = nocropco2Amp(0,:,:)
;nocropco2ampConf = conform_dims(dimsizes(nocropco2Amp),nocropco2amp1850,(/1,2/))
;nocropco2ampNorm = nocropco2Amp - nocropco2ampConf
;nocropco2ampNorm = nocropco2Amp - co2ampConf(120:,:,:) 
;nocropco2Trend   = dim_sum_n_Wrap(nocropco2ampNorm*area3d(120:,:,:),(/1,2/))/dim_sum_n_Wrap(area3d(120:,:,:),(/1,2/))
;Not area-weighted
;nocropco2Trend   = dim_avg_n_Wrap(nocropco2ampNorm, (/1,2/))
nocropco2Trend!0 = "yearsnocrop"
nocropco2Trend&yearsnocrop = yearsnocrop
;printVarSummary(nocropco2Trend)
print("CO2 Amp diff 1970 = "+nocropco2Trend(0) +", "+ (endyrnocrop+1970) +" = "+nocropco2Trend(endyrnocrop)+", and "+(nyrnocrop+1970)+" = "+nocropco2Trend(nyrnocrop-1))

;--------Obs----------
print("Observations")

;....Calculating average 10-year annual cycle....
obsco2yrpt     = obsco2yr(startyrobs:endyrobs,:,obsind(i))
obsdetrend     = dtrend(obsco2yrpt, False)
obsannual      = dim_avg_n_Wrap(obsdetrend, 0)
print(startyrobs+1968 + "-"+(endyrobs+1968)+ " CO2 amplitude in Obs = "+(dim_max_n_Wrap(obsannual,0) - dim_min_n_Wrap(obsannual,0)))

obsannualSD    = dim_stddev_n_Wrap(obsdetrend,0)
obsSD          = new((/2,nmon/),float)
obsSD!1        = "month"
obsSD&month    = month
obsSD(0,:)     = obsannual+obsannualSD
obsSD(1,:)     = obsannual-obsannualSD

;....Calculating each year's amplitude to generate time series....
obsMin         = dim_min_n_Wrap(obsco2yr(4:,:,obsind(i)),1)
obsMax         = dim_max_n_Wrap(obsco2yr(4:,:,obsind(i)),1)
obsAmp         = (obsMax - obsMin)
copy_VarMeta(obsMax,obsAmp)

obsTrend       = obsAmp
obsTrend!0     = "yearsobs"
obsTrend&yearsobs = yearsobs

print("CO2 Amplitude in 1972 = "+obsTrend(0) + ", "+ (endyrobs+1968) +" = "+obsTrend(endyrobs) + ", and "+(nyrobs+1968)+" = "+obsTrend(40))

;--------Stats---------

co2reg          = regline(yearsCESM2(122:162),co2Trend(122:162))
cesm1co2reg     = regline(yearsCESM1(122:),cesm1co2Trend(122:))
nocropco2reg    = regline(yearsnocrop(2:42),nocropco2Trend(2:42))
obsco2reg       = regline(yearsobs(4:),obsTrend(4:))

print(co2reg)
print(cesm1co2reg)
print(nocropco2reg)
print(obsco2reg)
;note: slope is the number printed: (0) slope


;------- Compiling All ---------
;...This only works when all are the same length...
  CO2Trend      = new((/4,nyrCESM2/),float)
  CO2Trend!1    = "yearsCESM2"
  CO2Trend&yearsCESM2= yearsCESM2

  co2dummy      = new(dimsizes(co2Trend),float) 

  CO2Trend(0,:) = (/co2dummy/)
  CO2Trend(1,:) = (/co2dummy/)
  CO2Trend(2,:) = (/co2Trend/)
  CO2Trend(3,:) = (/co2dummy/)

  CO2Cycle      = new((/4,nmon/),float) 
  CO2Cycle(0,:) = (/obsannual/)
  CO2Cycle(1,:) = (/cesm1co2annual/)
  CO2Cycle(2,:) = (/co2annual/)
  CO2Cycle(3,:) = (/nocropco2annual/)


;************* PLOTTING **************
print("Plotting Data")
;............Timeseries...............
res                        = True
wks                        = gsn_open_wks ("pdf", var+"_CESM_Timeseries_"+location(i))

res@xyDashPattern          = 0
res@gsnMaximize            = True
res@gsnFrame               = False
res@tiXAxisString          = "Year"
res@tiYAxisString          = "~F33~D ~F21~ CO~B~2~N~ Amplitude"+units   ;(g C m~S~-2~N~ day~S~-1~N~)"
res@gsnYRefLine            = 0.0
res@gsnYRefLineDashPattern = 1
res@gsnYRefLineThicknessF  = 1.5
res@xyLineThicknessF       = 3
res@tiMainString           = location(i)   ; add titles

;For normalized data
;res@trYMinF                = -5                ; use this and next line to change timescale that is graphed
;res@trYMaxF                = 10
;For absolute data
res@trYMinF                = 0                ; use this and next line to change timescale that is graphed
res@trYMaxF                = 20
res@trXMinF                = 1970                ; use this and next line to change timescale that is graphed
res@trXMaxF                = 2015


res@xyExplicitLegendLabels = (/" Observations"," CESM1"," CESM2"," CESM2 generic crop"/)
res@lgItemOrder            = (/ 3,2,1,0 /)  
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"
res@lgPerimOn              = False      ; No legend perimeter.
res@pmLegendParallelPosF   = .20                 ; move units right; note: used 0.25 for nocrop
res@pmLegendOrthogonalPosF = -0.26      ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res@pmLegendWidthF         = 0.075               ; Change width and
res@pmLegendHeightF        = 0.09               ; height of legend.
res@lgLabelFontHeightF     = .014                ; label font height

res@xyLineColors          = (/"black", "sienna3", "slateblue3", "steelblue3"/)
plotlines0                = gsn_csm_xy(wks,yearsCESM2,CO2Trend,res)
delete(res@xyLineColors)

res@pmLegendDisplayMode   = "Never"
res@xyLineColor           = (/"sienna3"/)
plotlines1                = gsn_csm_xy(wks,yearsCESM1,cesm1co2Trend,res)
res@xyLineColor           = (/"black"/)
plotlines2                = gsn_csm_xy(wks,yearsobs,obsTrend,res)
res@xyLineColor           = (/"steelblue3"/)
plotlines3                = gsn_csm_xy(wks,yearsnocrop,nocropco2Trend,res)


;...........AnnualCycle.............

res2                      = True
wks2                      = gsn_open_wks ("pdf", var+"_CESM_AnnualCycle_"+location(i))

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
res2@tiMainString           = location(i)   ; add titles

res2@trYMinF                = -15                ; use this and next line to change timescale that is graphed
res2@trYMaxF                = 15

res2@xyExplicitLegendLabels = (/" Observations"," CESM1"," CESM2"," CESM2 generic crop"/)
res2@lgItemOrder            = (/3,2,1,0/)    ; reorders the legend labels

res2@gsnXYFillColors  = "black"
res2@xyLineColor      = -1    ; makes the line transparent
res2@gsnXYFillOpacities = 0.2
plot                 = gsn_csm_xy(wks2,month,obsSD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

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

res2@xyLineColors          = (/"black", "sienna3", "slateblue3", "steelblue3"/)
plotlines2                  = gsn_csm_xy(wks2,month,CO2Cycle,res2)
delete(res2@xyLineColors)


;Note: If switching back to normalized timeseries, add ampNorm variables to this list
delete([/co2annualyrs,co2detrend,co2annual,co2annualSD/])
delete([/co2Min,co2Max,co2Amp,co2Trend,co2SD/])
delete([/cesm1co2annualyrs,cesm1co2detrend,cesm1co2annual,cesm1co2annualSD/])
delete([/cesm1co2Min,cesm1co2Max,cesm1co2Amp,cesm1co2Trend,cesm1co2SD/])
delete([/nocropco2annualyrs,nocropco2detrend,nocropco2annual,nocropco2annualSD/])
delete([/nocropco2Min,nocropco2Max,nocropco2Amp,nocropco2Trend,nocropco2SD/])
delete([/CO2Trend/])
delete([/obsco2yrpt,obsdetrend,obsannual,obsannualSD,obsSD,obsMin,obsMax,obsAmp,obsTrend/])

end do






