load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


simyrs             = "185001-201012"
avgyr              = "1991-2010"
startyr        = (1991 - 1850)
endyr          = (2010 - 1850)
;avgyr              = "1951-1970"
;startyr        = (1951 - 1850)
;endyr          = (1970 - 1850)
var                = "NEE"
;var                = "NEP"
;var                = "NBP"

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

psstr     = "ManagementAmplitudeSensitivity_"+var+"_"+avgyr

;------- VARIABLES -------------
lat            = data->lat
lon            = data->lon
nlat           = dimsizes(lat)
nlon           = dimsizes(lon)
years          = ispan(1850,2010,1)
month          = ispan(1,12,1)
avgyr          = "1991-2010"
area           = data->area
landfrac       = data->landfrac
aream          = area*1e6
landarea       = aream*landfrac
;startyr        = (1991 - 1850)*12       ;use when time is 1D
;endyr          = (2010 - 1850)*12 + 11  ;use when time is 1D
crop           = data->$var$
grain1dirr     = data2->$var$
grain1dfer     = data3->$var$
grain1dirf     = data4->$var$
grain1dluc     = data5->$var$
nocrop         = cropdata->$var$


printVarSummary(crop)
print(dimsizes(month))

ntim           =  dimsizes(crop(:,0,0))
nmon           =  12
nyr            =  ntim/nmon
print(nyr)


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

datastr    = varln+units

cropConv   = crop*convert
irrConv    = grain1dirr*convert
ferConv    = grain1dfer*convert
irfConv    = grain1dirf*convert
lucConv    = grain1dluc*convert
nocropConv = nocrop*convert

;.....Control......
crop4d        = reshape(cropConv,(/nyr,nmon,nlat,nlon/))
crop4d!0      = "years"
crop4d&years  = years
crop4d!1      = "month"
crop4d&month  = month
crop4d!2      = "lat"
crop4d&lat    = lat
crop4d!3      = "lon"
crop4d&lon    = lon

cropMax       = dim_max_n_Wrap(crop4d,1)
cropMin       = dim_min_n_Wrap(crop4d,1)
cropAmp       = (cropMax - cropMin)
copy_VarMeta(cropMax,cropAmp)
printVarSummary(cropAmp)

cropavg       = dim_avg_n_Wrap(cropAmp(startyr:endyr,:,:), 0)
printVarSummary(cropavg)

;.....Treatment.....
nocrop4d      = reshape(nocropConv,(/nyr,nmon,nlat,nlon/))
copy_VarMeta(crop4d,nocrop4d)

nocropMax     = dim_max_n_Wrap(nocrop4d,1)
nocropMin     = dim_min_n_Wrap(nocrop4d,1)
nocropAmp     = (nocropMax - nocropMin)
copy_VarMeta(nocropMax,nocropAmp)

nocropavg     = dim_avg_n_Wrap(nocropAmp(startyr:endyr,:,:), 0)

;Sensitivities
grainirr4d    = reshape(irrConv,(/nyr,nmon,nlat,nlon/))
grainfer4d    = reshape(ferConv,(/nyr,nmon,nlat,nlon/))
grainirf4d    = reshape(irfConv,(/nyr,nmon,nlat,nlon/))
grainluc4d    = reshape(lucConv,(/nyr,nmon,nlat,nlon/))

copy_VarMeta(crop4d,grainirr4d)
copy_VarMeta(crop4d,grainfer4d)
copy_VarMeta(crop4d,grainirf4d)
copy_VarMeta(crop4d,grainluc4d)


irrAmp        = (dim_max_n_Wrap(grainirr4d,1) - dim_min_n_Wrap(grainirr4d,1))
ferAmp        = (dim_max_n_Wrap(grainfer4d,1) - dim_min_n_Wrap(grainfer4d,1))
irfAmp        = (dim_max_n_Wrap(grainirf4d,1) - dim_min_n_Wrap(grainirf4d,1))
lucAmp        = (dim_max_n_Wrap(grainluc4d,1) - dim_min_n_Wrap(grainluc4d,1))

copy_VarMeta(cropMax,irrAmp)
copy_VarMeta(cropMax,ferAmp)
copy_VarMeta(cropMax,irfAmp)
copy_VarMeta(cropMax,lucAmp)

irravg        = dim_avg_n_Wrap(irrAmp(startyr:endyr,:,:), 0)
feravg        = dim_avg_n_Wrap(ferAmp(startyr:endyr,:,:), 0)
irfavg        = dim_avg_n_Wrap(irfAmp(startyr:endyr,:,:), 0)
lucavg        = dim_avg_n_Wrap(lucAmp(startyr:endyr,:,:), 0)



;***** Plotting *****
;Note: Plotting only for global maps

print(psstr)
  wks     =  gsn_open_wks( "pdf", psstr)

  gsn_define_colormap(wks, "WhViBlGrYeOrRe")

  res                       = True             ; turn on plotting options
  res@lbLabelBarOn          = False
  res@gsnSpreadColors       = True             ; spans all colors in colormap
  res@cnFillOn              = True             ; turn on color fill
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour line labels
  res@cnLevelSelectionMode  = "ExplicitLevels"   ;

  if (var .eq. "NEE") then
    res@cnLevels              = ((/0.5,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0/))
  end if
  if (var .eq. "NEP") then
    res@cnLevels              = ((/0.5,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0/))
;    res@cnLevels              = ((/0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0/))
  end if
  if (var .eq. "NBP") then
    res@cnLevels              = ((/0.5,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0/))
;    res@cnLevels              = ((/0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0/))
  end if


  res@mpProjection          = "robinson"       ; Robinson grid projection
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@lbAutoManage          = False
  res@lbLabelFontHeightF    = 0.015
  res@txFontHeightF         = 0.025
  res@cnRasterModeOn        = True


  plots                      = new(6,graphic)

;  res@cnMinLevelValF         = 0       ; min value to plot
;  res@cnMaxLevelValF         = 10   ;4500          ; max value to plot
;  res@cnLevelSpacingF        = 1       ; sets frequency of colors on colormap

  res@gsnLeftString          = ""
  res@gsnRightString         = ""
  res@gsnCenterString        = ""

  res@tiMainString          = "Generic Crop"
  plots(0)                   = gsn_csm_contour_map(wks,nocropavg,res)

  res@tiMainString          = "Active Crop"
  plots(1)                   = gsn_csm_contour_map(wks,cropavg,res)

  res@tiMainString          = "No Fertilization"
  plots(2)                   = gsn_csm_contour_map(wks,feravg,res)

  res@tiMainString          = "No Irrigation"
  plots(3)                   = gsn_csm_contour_map(wks,irravg,res)

  res@tiMainString          = "No Fertilization or Irrigation"
  plots(4)                   = gsn_csm_contour_map(wks,irfavg,res)

  res@tiMainString          = "No Land Use Change"
  plots(5)                   = gsn_csm_contour_map(wks,lucavg,res)

  


  pres                      = True
  pres@gsnFrame             = False
  pres@lbTitleString        = datastr
  pres@lbTitlePosition      = "Bottom"
  pres@lbTitleFontHeightF   = 0.015
  pres@lbLabelFontHeightF   = 0.01
  pres@gsnPanelLabelBar     = True
  pres@gsnPanelBottom       = 0.05
  pres@gsnPanelYWhiteSpacePercent = 5

  gsn_panel(wks,plots,(/3,2/),pres)
  frame(wks)
























