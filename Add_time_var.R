library(ncdf4)
library(raster)
library(rasterVis)
library(plotrix)
library(maps)

rm(list = ls())
setwd("~/Desktop/Studi_Yosik/Friends/adol/Gsmap2nc/output/")
load("../../../../data/topograp.rda")
f = dir()
tahun = substr(f,7,10)
bulan = substr(f,11,12)
tanggal = substr(f,13,14)
jam = substr(f,16,17)

nc = list()
for(i in 1:length(f)){
  nc[[i]] <- nc_open(f[i])
}

lon = ncvar_get(nc[[1]],"lon")
lat = ncvar_get(nc[[1]],"lat")
pcp = array(0,dim = c(length(lon),length(lat),length(nc)))
for(i in 1:length(f)){
  pcp[,,i] <- ncvar_get(nc[[i]])
}

# ------------------- PERSENTILE 95 ------------------ #
q9=c()
for(i in 1:length(f)){
  q9[i] = quantile(as.numeric(pcp[,,i]),0.95)
  pcp[,,i][pcp[,,i] <= q9[i]] = 0
}

ave = apply(pcp,c(1,2),FUN=mean)
ave[ave <= 0] = NA
ave = as.matrix(disaggregate(raster(ave), 10, method='bilinear'))
lon=seq(lon[1],lon[length(lon)],length=dim(ave)[1])
lat=seq(lat[1],lat[length(lat)],length=dim(ave)[2])
rgb.palette <- colorRampPalette(c("white","black","blue","white","red"),alpha=1)
# rgb.palette <- colorRampPalette(c("lightblue","green","yellow","red"),alpha=1)

x11(height = 7,width = 9)
map("world", fill=F, col="pink", lwd = 2,bg=NA, xlim=c(lon[1],lon[length(lon)]), 
    ylim=c(lat[1], lat[length(lat)]),
    resolution=0.00001)
image(topograp$xnya,topograp$ynya,topograp$el,axes=FALSE,xlab='Longitude',
      ylab='Latitude',col=terrain.colors(10,alpha = 0.5),add=T)
image(lon,lat,ave,col=rgb.palette(100),main = "Hourly Gsmap  extreme weather Percentile 95",add =T)
box()
grid(ny=10,nx=9)
# contour(lon,lat,ave,add=T,nlevels=5)