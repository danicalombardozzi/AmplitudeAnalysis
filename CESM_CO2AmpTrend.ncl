load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


simyrs             = "185001-201412"
var                = "CO2"

;datadir            = "/gpfs/fs1/collections/cdg/timeseries-cmip6/"
datadir            = "/glade/scratch/dll/"
print("data directory = "+datadir)

subdir             = "/atm/proc/tseries/month_1/"

sim                = "b.e21.BHIST_BPRP.f09_g17.CMIP6-esm-hist.001"

;data               = addfile(datadir+sim+subdir+sim+".cam.h0."+var+"."+simyrs+".nc","r")
data               = addfile(datadir+sim+".cam.h0."+var+"."+simyrs+".nc","r")

;.......
dir2               = "/glade/scratch/klindsay/archive/"
sim2               = "b40.20th.1deg.coup.001"
subdir2            = "/atm/proc/tseries/monthly/"

data2              = addfile(dir2+sim2+subdir2+sim2+".cam2.h0."+var+".185001-200512.nc","r")


;------- VARIABLES -------------
lat            = data->lat
lon            = data->lon
nlat           = dimsizes(lat)
nlon           = dimsizes(lon)
;years          = ispan(1850,2014,1)
years          = ispan(1850,2005,1)
month          = ispan(1,12,1)

;For 1995-2014
;avgyr          = "1995-2014"
;startyr        = (1995 - 1850)
;endyr          = (2014 - 1850)
avgyr          = "1995-2005"
startyr        = (1995 - 1850)
endyr          = (2005 - 1850)
print(startyr)
print(endyr)

startmo        = (startyr+1)*12
endmo          = (endyr+1)*12

co2            = data->$var$(:1871,31,:,:)
cesm1co2       = data2->$var$(:,25,:,:)

printVarSummary(co2)
printVarSummary(cesm1co2)

;------------------------------

ntim           =  dimsizes(co2(:,0,0))
nmon           =  12
nyr            =  ntim/nmon
print(nyr)

if (var .eq. "CO2") then
  varln     = "CO~B~2~N~ "
  units     = " (ppm)"
  convert   = 1.0e6 * 28.966 / 44.0 
end if


datastr   = varln+units

co2       = co2*convert
cesm1co2  = cesm1co2*convert


;--------CESM2-----------
co2surf4d       = reshape(co2,(/nyr,nmon,nlat,nlon/))
co2surf4d!0     = "year"
co2surf4d!1     = "month"
co2surf4d!2     = "lat"
co2surf4d&lat   = lat
co2surf4d!3     = "lon"
co2surf4d&lon   = lon
co2annualyrs    = dim_avg_n_Wrap(co2surf4d(startyr:endyr,:,{30:},:),(/2,3/))
co2annavg       = avg(co2annualyrs)
printVarSummary(co2annavg)

co2annual       = dim_avg_n_Wrap(co2annualyrs,0)
co2conform     = conform_dims(dimsizes(co2annual),co2annavg,0)
co2norm        = co2annual - co2conform 
copy_VarMeta(co2annual,co2norm)

;printVarSummary(co2norm)
;print(co2norm)

co2annualSD     = dim_stddev_n_Wrap(co2norm,0)

;printVarSummary(co2annual)
;printVarSummary(co2annualSD)

co2amp          = dim_avg_n_Wrap(co2surf4d(endyr-2:endyr,:,{30:},:),(/2,3/))
co2yravg        = dim_avg_n_Wrap(co2amp,0)

print(endyr-2+1850 + "-"+(endyr+1850)+ " CO2 amplitude in CESM2 = "+(dim_max_n_Wrap(co2yravg,0) - dim_min_n_Wrap(co2yravg,0)))

co2Min     = dim_min_n_Wrap(co2surf4d(:,:,{30:},:),1)
co2Max     = dim_max_n_Wrap(co2surf4d(:,:,{30:},:),1)
co2Amp     = (co2Max - co2Min)
copy_VarMeta(co2Max,co2Amp)
printVarSummary(co2Amp)

co2amp1850 = co2Amp(0,:,:)
co2ampConf = conform_dims(dimsizes(co2Amp),co2amp1850,(/1,2/))

co2ampNorm = co2Amp - co2ampConf

;..example of weighting from LUMIP script ...
;cropTrend   = dim_sum_n_Wrap(cropAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))

;NOTE: co2Trend is not area-weighted
co2Trend   = dim_avg_n_Wrap(co2ampNorm, (/1,2/))
co2Trend!0 = "years"
co2Trend&years = years
printVarSummary(co2Trend)
print("CO2 Amp diff 1960 = "+co2Trend(110) +"and "+ (endyr+1850) +" = "+co2Trend(endyr))

co2SD      = new((/2,nmon/),float)
co2SD!1    = "month"
co2SD&month= month
co2SD(0,:) = co2norm+co2annualSD
co2SD(1,:) = co2norm-co2annualSD


;--------CESM1-----------
cesm1co2surf4d       = reshape(cesm1co2,(/nyr,nmon,nlat,nlon/))
cesm1co2surf4d!2     = "lat"
cesm1co2surf4d&lat   = lat
cesm1co2surf4d!3     = "lon"
cesm1co2surf4d&lon   = lon
cesm1co2annualyrs    = dim_avg_n_Wrap(cesm1co2surf4d(startyr:endyr,:,{30:},:),(/2,3/))
cesm1co2annual       = dim_avg_n_Wrap(cesm1co2annualyrs,0)
cesm1co2annavg       = avg(cesm1co2annualyrs)
cesm1co2conform     = conform_dims(dimsizes(cesm1co2annual),cesm1co2annavg,0)
cesm1co2norm        = cesm1co2annual - cesm1co2conform
copy_VarMeta(cesm1co2annual,cesm1co2norm)

cesm1co2annualSD     = dim_stddev_n_Wrap(cesm1co2norm,0)

;printVarSummary(cesm1co2norm)
;printVarSummary(cesm1co2annualSD)

cesm1co2amp          = dim_avg_n_Wrap(cesm1co2surf4d(endyr-2:endyr,:,{30:},:),(/2,3/))
cesm1co2yravg        = dim_avg_n_Wrap(cesm1co2amp,0)

print(endyr-2+1850 + "-"+(endyr+1850)+ " CO2 amplitude in CESM1 = "+(dim_max_n_Wrap(cesm1co2yravg,0) - dim_min_n_Wrap(cesm1co2yravg,0)))

cesm1co2Min     = dim_min_n_Wrap(cesm1co2surf4d(:,:,{30:},:),1)
cesm1co2Max     = dim_max_n_Wrap(cesm1co2surf4d(:,:,{30:},:),1)
cesm1co2Amp     = (cesm1co2Max - cesm1co2Min)
copy_VarMeta(cesm1co2Max,cesm1co2Amp)
printVarSummary(cesm1co2Amp)

cesm1co2amp1850 = cesm1co2Amp(0,:,:)
cesm1co2ampConf = conform_dims(dimsizes(cesm1co2Amp),cesm1co2amp1850,(/1,2/))

cesm1co2ampNorm = cesm1co2Amp - cesm1co2ampConf

;..example of weighting from LUMIP script ...
;cropTrend   = dim_sum_n_Wrap(cropAmpNorm*landarea3d,(/1,2/))/dim_sum_n_Wrap(landarea3d,(/1,2/))

;NOTE: cesm1co2Trend is not area-weighted
cesm1co2Trend   = dim_avg_n_Wrap(cesm1co2ampNorm, (/1,2/))
cesm1co2Trend!0 = "years"
cesm1co2Trend&years = years
printVarSummary(cesm1co2Trend)
print("CO2 Amp diff 1960 = "+cesm1co2Trend(110) +"and "+ (endyr+1850) +" = "+cesm1co2Trend(endyr))

cesm1co2SD      = new((/2,nmon/),float)
cesm1co2SD!1    = "month"
cesm1co2SD&month= month
cesm1co2SD(0,:) = cesm1co2norm+cesm1co2annualSD
cesm1co2SD(1,:) = cesm1co2norm-cesm1co2annualSD


;------- Compiling All ---------
  CO2Trend      = new((/2,nyr/),float)
  CO2Trend!1    = "years"
  CO2Trend&years= years

  CO2Trend(0,:) = (/co2Trend/)
  CO2Trend(1,:) = (/cesm1co2Trend/)

  CO2Cycle      = co2SD
  CO2Cycle(0,:) = (/co2norm/)
  CO2Cycle(1,:) = (/cesm1co2norm/)

;************* PLOTTING **************
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
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"

res@xyExplicitLegendLabels = (/" CESM2", " CESM1"/)
res@lgItemOrder            = (/1,0/)    ; reorders the legend labels
res@xyLineColors           = (/"black","red"/)

res@pmLegendParallelPosF   = .10                 ; move units right; note: used 0.25 for nocrop
res@pmLegendOrthogonalPosF = -0.25       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res@pmLegendWidthF         = 0.075               ; Change width and
res@pmLegendHeightF        = 0.10                ; height of legend.
res@lgLabelFontHeightF     = .015                ; label font height

plotlines                 = gsn_csm_xy(wks,years,CO2Trend,res)


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


res2@trYMinF                = -15                ; use this and next line to change timescale that is graphed
res2@trYMaxF                = 15

res2@xyExplicitLegendLabels = (/" CESM2 ", " CESM1 "/)
res2@lgItemOrder            = (/1,0/)    ; reorders the legend labels

res2@gsnXYFillColors  = "black"
res2@xyLineColor      = -1    ; makes the line transparent
res2@gsnXYFillOpacities = 0.2
plot                 = gsn_csm_xy(wks2,month,co2SD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

res2@gsnXYFillColors = "red"
res2@xyLineColor     = -1
nextplot            = gsn_csm_xy(wks2,month,cesm1co2SD,res2)
delete(res2@gsnXYFillColors)
delete(res2@xyLineColor)

res2@pmLegendParallelPosF   = .10                 ; move units right; note: used 0.25 for nocrop
res2@pmLegendOrthogonalPosF = -0.325       ;-0.325  ;for legend @ top, -0.475 for legend @ bottom   ; move units down
res2@pmLegendWidthF         = 0.075               ; Change width and
res2@pmLegendHeightF        = 0.10                ; height of legend.
res2@lgLabelFontHeightF     = .015                 ; label font height

res2@xyLineColors           = (/"black","red"/)
plotlines2                  = gsn_csm_xy(wks2,month,CO2Cycle,res2)








