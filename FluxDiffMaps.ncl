load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"


simyrs             = "185001-201012"
avgyr              = "1991-2010"
;avgyr              = "1951-1970"
;var                = "NEE"
;var                = "NEP"
;var                = "NBP"
;var                = "NPP"
;var                = "HR"
var                = "AR"

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

psstr     = "FluxMap_"+var+"_"+avgyr

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
startyr        = (1991 - 1850)*12       ;use when time is 1D
endyr          = (2010 - 1850)*12 + 11  ;use when time is 1D
crop           = data->$var$
nocrop         = cropdata->$var$

;startyr        = (1991 - 1850)
;endyr          = (2010 - 1850)
;startyr        = (1951 - 1850)
;endyr          = (1970 - 1850)


printVarSummary(crop)
print(dimsizes(month))

ntim           =  dimsizes(crop(:,0,0))
nmon           =  12
nyr            =  ntim/nmon
print(nyr)

if (var .eq. "NEE") then
  varln     = "Net Ecosystem Exchange"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if
if (var .eq. "NEP") then
  varln     = "Net Ecosystem Production"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if
if (var .eq. "NBP") then
  varln     = "Net Biome Production"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if
if (var .eq. "NPP") then
  varln     = "Net Primary Productivity"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if
if (var .eq. "HR") then
  varln     = "Heterotrophic Respiration"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if
if (var .eq. "AR") then
  varln     = "Autotrophic Respiration"
  units     = " (g C m~S~-2~N~ yr~S~-1~N~)"
  convert   = 60*60*24*365
end if

datastr    = varln+units

cropConv   = crop*convert
nocropConv = nocrop*convert

;.....Control......

cropavg       = dim_avg_n_Wrap(cropConv(startyr:endyr,:,:), 0)
printVarSummary(cropavg)

cropavg!0      = "lat"
cropavg&lat    = lat
cropavg!1      = "lon"
cropavg&lon    = lon

;.....Treatment.....

nocropavg     = dim_avg_n_Wrap(nocropConv(startyr:endyr,:,:), 0)
printVarSummary(nocropavg)
copy_VarMeta(cropavg,nocropavg)


cropminusnocrop  = cropavg - nocropavg
copy_VarMeta(cropavg,cropminusnocrop) 

printVarSummary(cropminusnocrop)


;***** Plotting *****
;Note: Plotting only for global maps

print(psstr)
  wks     =  gsn_open_wks( "pdf", psstr)

;  gsn_define_colormap(wks, "WhViBlGrYeOrRe")
  gsn_define_colormap(wks, "BlueDarkRed18")

  res                       = True             ; turn on plotting options
  res@lbLabelBarOn          = False
  res@gsnSpreadColors       = True             ; spans all colors in colormap
  res@cnFillOn              = True             ; turn on color fill
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour line labels
  res@cnLevelSelectionMode  = "ExplicitLevels"   ;

  if (var .eq. "NEE") then
    res@cnLevels              = ((/-100,-80,-60,-40,-20,0,20,40,60,80,100/))
;    res@cnLevels              = ((/-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2/))
;    res@cnLevels              = ((/-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8/))
  end if
  if (var .eq. "NEP") then
;    res@cnLevels              = ((/-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2/))
    res@cnLevels              = ((/-100,-80,-60,-40,-20,0,20,40,60,80,100/))
;    res@cnLevels              = ((/-60,-40,-20,-10,-5,-1,0,1,5,10,20,40,60/))
;    res@cnLevels              = ((/-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8/))
  end if
  if (var .eq. "NBP") then
;    res@cnLevels              = ((/-0.2,-0.15,-0.1,-0.05,0,0.05,0.1,0.15,0.2/))
    res@cnLevels              = ((/-60,-40,-20,-10,-5,-1,0,1,5,10,20,40,60/))
  end if
  if (var .eq. "NPP") then
    res@cnLevels              = ((/-800,-400,-200,-100,-50,-25,25,50,100,200,400,800/))
  end if
  if (var .eq. "HR") then
    res@cnLevels              = ((/-800,-400,-200,-100,-50,-25,25,50,100,200,400,800/))
  end if
  if (var .eq. "AR") then
    res@cnLevels              = ((/-800,-400,-200,-100,-50,-25,25,50,100,200,400,800/))
  end if

  res@mpProjection          = "robinson"       ; Robinson grid projection
  res@gsnDraw               = False
  res@gsnFrame              = False
  res@lbAutoManage          = False
  res@lbLabelFontHeightF    = 0.015
  res@txFontHeightF         = 0.025
  res@cnRasterModeOn        = True


  plots                      = new(3,graphic)

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

;  delete(res@cnLevels)
;  res@cnLevels              = ((/-8,-6,-4,-2,0,2,4,6,8/))

  res@tiMainString          = "Difference: Active minus Generic"
  plots(2)                  = gsn_csm_contour_map(wks,cropminusnocrop,res)

  pres                      = True
  pres@gsnFrame             = False
  pres@lbTitleString        = datastr
  pres@lbTitlePosition      = "Bottom"
  pres@lbTitleFontHeightF   = 0.015
  pres@lbLabelFontHeightF   = 0.01
  pres@gsnPanelLabelBar     = True
  pres@gsnPanelBottom       = 0.05
  pres@gsnPanelYWhiteSpacePercent = 5

  gsn_panel(wks,plots,(/3,1/),pres)
  frame(wks)
























