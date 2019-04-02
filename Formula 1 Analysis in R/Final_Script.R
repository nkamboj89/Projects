
##Installing Packages (To Install remove the hash)
#install.packages('plotGoogleMaps')
#install.packages("RgoogleMaps")
#install.packages("plyr")
#install.packages("sqldf")
#install.packages("ggplot2")
#install.packages("gridExtra")
#install.packages("ggthemes")
#install.packages("RColorBrewer")
#install.packages(grid)
#install.packages(gridExtra)
#install.packages(ggrepel)
#install.packages(viridis)
#install.packages(circlize)
#install.packages("jpeg")

##Running Libraries
library(plotGoogleMaps)
library(RgoogleMaps)
library(plyr)
library(sqldf)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(ggthemes)
library(RColorBrewer)
library(grid)
library(gridExtra)
library(ggrepel)
library(viridis)
library(circlize)
library(jpeg)

#Cleaning Data

#Remving column with invalid values
library(readr)
races <- read_csv("~/Desktop/Spring 2018/CIS 5270/Project 2/data/Dirty/races.csv")
races_dirty <- races
#View(races_dirty)
races_clean <- subset(races_dirty, select = -date)
#View(races_clean)
revised_races <- races_clean

#Removing repetitive rows
lap_times <- read.csv("~/Desktop/Spring 2018/CIS 5270/Project 2/data/Dirty/lapTimes.csv", sep = ',')
View(lap_times)
duplicated(lap_times)
which(duplicated(lap_times))
clean_lap_times <- lap_times[!duplicated(lap_times), ]
#View(clean_lap_times)
which(duplicated(clean_lap_times)) #will retern only integer(0) as it now only repetative
revised_lap_times <- clean_lap_times

#Converting invalid date to DOB format
drivers <- read.csv("~/Desktop/Spring 2018/CIS 5270/Project 2/data/Dirty/drivers.csv", sep = ',')
View(drivers)
revised_drivers <- transform(drivers, x = as.Date(as.character(dob), "%Y%m%d"))
#View(revised_drivers)


##Writing cleaned dataframes into CSV
write.csv(revised_races, file = "races.csv")
write.csv(revised_lap_times, file = "lapTimes.csv")
write.csv(revised_drivers, file = "drivers.csv")


setwd("~/Desktop/Spring 2018/CIS 5270/Project 2/data")
map<-read.csv("circuits.csv", sep=',')
#View(map)
coordinates(map) <- cbind(map$lng, map$lat)
#View(coordinates(map))
proj4string(map) = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
a <-plotGoogleMaps::plotGoogleMaps(map) #for somereason this one keep crashing

#Static Map (this only works)
#center = c(54.5260, 15.2551) #If want to display onlt EU tracks
center = c(mean(map$lat), mean(map$lng))
zoom <- 3
a <- GetMap(center = center, zoom = zoom)
PlotOnStaticMap(a, lat = (map$lat), lon = (map$lng), pch = 20, col =c('red', 'blue', 'green'))

#Joining using SQLlibrary
race <- read.csv('results.csv', sep = ',')
status <- read.csv ('status.csv', sep = ',')
joined <- join(race, status, type = "inner")
View(joined)
df=sqldf("SELECT raceid, driverid, status FROM joined WHERE status <> 'Finished' and status NOT LIKE '+%'  GROUP BY status, driverid")
View(df)
races<-read.csv('races.csv', sep = ',')
joined2 <- join(df, races, type = "inner")
df2 <- sqldf("SELECT driverid, status, year, name FROM joined2 WHERE year > 2003")
driver <- read.csv('drivers.csv', sep = ',')
drvr <- sqldf("SELECT driverid, nationality FROM driver")
joined3 <- join(df2, drvr, type = "inner")
View(joined3)
final<- data.frame(name = joined3$nationality, x = joined3$status, y = joined3$year, z = joined3$name)
#View(final)

#Bar chart
theme_set(theme_classic())
g <- ggplot(joined3, aes(status))
g + geom_bar(aes(fill=nationality), width = 0.5) + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) + 
  labs(title="Factors leading to not completing race over 13 years", subtitle="Nationality wise")

#Time series plot 
ggplot(joined3, aes(x=year)) + 
  geom_line(aes(y=status)) + 
  labs(title="Time Series Chart", 
       subtitle="Showing factors leading to DNF over 13 years", 
       y="Failures Factors")

#Statistical Averages
#Joining constructorResults and cosntructors for average points of constructors
setwd("~/Desktop/Spring 2018/CIS 5270/Project 2/data")
#cons_res <- read.csv('constructorResults.csv', sep = ',')
cons <- read.csv('constructors.csv', sep = ',')
cons_stnd <- read.csv('constructorStandings.csv', sep = ',')
join_cons <-inner_join(
  cons %>% dplyr::select(constructorId, name), 
  cons_stnd %>% dplyr::select(constructorId, points), 
  by='constructorId')
View(join_cons)
cons_stat <- sqldf('SELECT name, points FROM join_cons GROUP BY name')
#View(cons_stat)
cons_mean <- ddply(cons_stat, .(name), summarize,  Points_Mean=mean(points))
cons_mean<- sqldf('SELECT * FROM cons_mean WHERE Points_Mean > 10')
#View(cons_mean)
#Plot
#ggplot(data=cons_mean, aes(x=name, y=Points_Mean, group=name, colour=name)) + geom_line() + geom_point()
ggplot(cons_mean, aes(Points_Mean, name)) + geom_jitter(alpha = I(1), aes(color=name))

Summary(cons_stat)

#####ADDITION
setwd("~/Desktop/Spring 2018/CIS 5270/Project 2/data")
constructors <- read.csv("constructors.csv", sep = ',')
drivers <- read.csv("drivers.csv", sep = ',')
driverStandings <- read.csv("driverStandings.csv", sep = ',')
races <- read.csv("races.csv", sep = ',')
results <- read.csv("results.csv", sep = ',')
# Some inspection
#head(results,150)
#str(drivers)
# Filter just each winner
filter_winner <- (results$positionText=="1")
winners <- results[filter_winner,]
# Merging two data frames to obtain a new data frame
# with just the winners and their nationalities
results.by.driver <- merge(x=winners[,c("raceId", "driverId","position")], y=drivers[,c("driverId","driverRef","nationality")], by="driverId")
races.by.driver <- merge(x=results[,c("raceId","driverId","position")], y=drivers[,c("driverId","driverRef","nationality")], by="driverId")

# Build a new data frame with the amount of wins and amount
# of races by country. Somewhat dirty implementation
wins.by.country <- summary(results.by.driver$nationality)
races.by.country <- summary(races.by.driver$nationality)
win.percentage.by.country = data.frame(wins.by.country,races.by.country)

# Add the nationality column
win.percentage.by.country$nationality <- rownames(win.percentage.by.country)
# Add the percentage column
win.percentage.by.country$percentage <- 100*(win.percentage.by.country$wins.by.country)/(win.percentage.by.country$races.by.country)
# Remove countries with no wins (that came from the races.by.country)
filter2 <- win.percentage.by.country$wins.by.country > 0
win.percentage.by.country <- win.percentage.by.country[filter2,]
#head(win.percentage.by.country) # Uncomment to check the new data frame

plt3 <- ggplot(data=win.percentage.by.country, aes(x=reorder(nationality,-percentage), y=percentage))
plt3 <- plt3 + geom_bar(stat="identity", fill="#8cd98c", color="Black") + xlab("Nationality") + ylab("Win ratio (%)") + ggtitle("Number of races won by nationality") +
  ylim(0,11.9) + theme(axis.text.x = element_text(angle=90,hjust=1,vjust=0.25), plot.title = element_text(hjust=0.5)) 

arg <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/argentina.jpg")
ger <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/germany.jpg")
grb <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/uk.jpg")
ast <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/austria.jpg")
can <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/canada.jpg")
col <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/colombia.jpg")
aus <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/australia.jpg")
bra <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/brazil.jpg")
fin <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/finland.jpg")
spa <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/spain.jpg")
saf <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/south-africa.jpg")
nze <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/new-zealand.jpg")
fra <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/france.jpg")
usa <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/usa.jpg")
swe <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/sweden.jpg")
bel <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/belgium.jpg")
swi <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/switzerland.jpg")
pol <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/poland.jpg")
ita <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/italy.jpg")
ven <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/venezuela.jpg")
net <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/netherlands.jpg")
mex <- readJPEG("~/Desktop/Spring 2018/CIS 5270/Project 2/addition/flags/mexico.jpg")


plt3 + annotation_raster(arg, ymin = 10.5,ymax=11,xmin=0.5,xmax=1.5) +
  annotation_raster(ger, ymin = 8.0,ymax=8.4,xmin=1.6,xmax=2.4) +
  annotation_raster(grb, ymin = 6.5,ymax=6.9,xmin=2.6,xmax=3.4) +
  annotation_raster(ast, ymin = 6.0,ymax=6.4,xmin=3.6,xmax=4.4) +
  annotation_raster(can, ymin = 6.0,ymax=6.35,xmin=4.6,xmax=5.4) +
  annotation_raster(col, ymin = 5.7,ymax=6.1,xmin=5.6,xmax=6.4) +
  annotation_raster(aus, ymin = 5.7,ymax=6.1,xmin=6.6,xmax=7.4) +
  annotation_raster(bra, ymin = 5.3,ymax=5.7,xmin=7.6,xmax=8.4) +
  annotation_raster(fin, ymin = 5.2,ymax=5.6,xmin=8.6,xmax=9.4) +
  annotation_raster(spa, ymin = 5.0,ymax=5.4,xmin=9.6,xmax=10.4) +
  annotation_raster(saf, ymin = 4.9,ymax=5.3,xmin=10.6,xmax=11.4) +
  annotation_raster(nze, ymin = 3.3,ymax=3.7,xmin=11.6,xmax=12.4) +
  annotation_raster(fra, ymin = 3.0,ymax=3.4,xmin=12.6,xmax=13.4) +
  annotation_raster(usa, ymin = 2.7,ymax=3.1,xmin=13.6,xmax=14.4) +
  annotation_raster(swe, ymin = 2.55,ymax=2.95,xmin=14.6,xmax=15.4) +
  annotation_raster(bel, ymin = 2.0,ymax=2.4,xmin=15.6,xmax=16.4) +
  annotation_raster(swi, ymin = 1.5,ymax=2.1,xmin=16.6,xmax=17.4) +
  annotation_raster(pol, ymin = 1.4,ymax=1.8,xmin=17.6,xmax=18.4) +
  annotation_raster(ita, ymin = 1.35,ymax=1.75,xmin=18.6,xmax=19.4) +
  annotation_raster(ven, ymin = 0.9,ymax=1.3,xmin=19.6,xmax=20.4) +
  annotation_raster(net, ymin = 0.9,ymax=1.3,xmin=20.6,xmax=21.4) +
  annotation_raster(mex, ymin = 0.7,ymax=1.1,xmin=21.6,xmax=22.4) 


setwd("~/Desktop/Spring 2018/CIS 5270/Project 2/data")
results<-read.csv('results.csv',sep=',',stringsAsFactors=F)
results$fastestLapSpeed<-as.numeric(results$fastestLapSpeed)
results$fastestLapTimeNum<-sapply(results$fastestLapTime, convertFastestLap)
races<-read.csv('races.csv',stringsAsFactors=F,sep=',')
races$date<-as.Date(races$date,"%Y-%m-%d")
races$name<-gsub(" Grand Prix","",races$name)
results_2<-left_join(
  results %>% dplyr::select(-time, -fastestLapTime), 
  races %>% dplyr::select(-time, -url), 
  by='raceId')
circuits<-read.csv('circuits.csv',sep=",",stringsAsFactors=F)
races<-left_join(races %>% select(-name,-url), circuits %>% select(-url), by='circuitId')
drivers<-read.csv('drivers.csv',sep=',',stringsAsFactors=F)
drivers$age_driver <- 2017 - sapply(drivers$dob, function(x) as.numeric(strsplit(x,'/')[[1]][3]))
driversStandings<-read.csv('driverStandings.csv',sep=',',stringsAsFactors=F)
drivers<-left_join(drivers %>% select(-url), driversStandings,by='driverId')

results_3<-left_join(
  results, 
  drivers %>% dplyr::rename(number_drivers = number) %>% select(-points, -position, -positionText),
  by=c('driverId','raceId')) 
results_3<-left_join(results_3,races %>% select(-time), by='raceId')

constructors<-read.csv('constructors.csv',sep=',',stringsAsFactors=F)
constructorStandings<-read.csv('constructorStandings.csv',sep=',',stringsAsFactors=F)
constructorResults<-read.csv("constructorResults.csv",sep=",",stringsAsFactors=F)

constructorResults<-left_join(
  constructorResults,
  races %>% rename(name_races = name), by='raceId')

constructorResults <- left_join(constructorResults, constructors %>% select(-url) %>% rename(name_constructor = name), by='constructorId')
constructorResults <- left_join(constructorResults, constructorStandings %>% rename(point_constructor = points) %>% select(-X), by=c('constructorId','raceId'))

results_4<-left_join(
  results_3, 
  constructorResults %>% select(-position,-positionText,-points,-X,-country,-wins,-lng,-lat,-alt,-nationality,-circuitRef,-round, -circuitId,-year,-time,-date,-location),
  by=c('raceId','constructorId'))
temp<-data.frame(
  results_4 %>% filter(position==1) %>% 
    group_by(name_constructor, driverRef) %>% 
    summarize(count=n()) %>% filter(count>5) %>% na.omit())

#prepare colors
names<-sort(unique(temp$name_constructor))
color <- c('#87CEEB',"gray50","gray50","#FFFFE0","gray50","#006400",'#EE0000','#1E90FF','gray50','#006400','#7F7F7F','#7F7F7F','#9C661F','#FFD700','gray50','gray50','#EEEEE0')
COL<-data.frame(name_constructor = names,color)
temp2<-data.frame(left_join(temp, COL, by='name_constructor'))

chordDiagram(temp2[,c(1:2)],transparency = 0.5, grid.col = append(color,rep('aliceblue',32)), col= as.character(temp2$color),annotationTrack = "grid", preAllocateTracks = 1)

circos.trackPlotRegion(
  track.index = 1, 
  panel.fun = function(x, y) {
    xlim = get.cell.meta.data("xlim")
    ylim = get.cell.meta.data("ylim")
    sector.name = get.cell.meta.data("sector.index")
    circos.text(
      mean(xlim), 
      ylim[1], 
      sector.name, 
      facing = "clockwise", 
      niceFacing = TRUE, 
      adj = c(0, 0.25), 
      cex=.7)
    circos.axis(
      h = "top", 
      labels.cex = 0.5, 
      major.tick.percentage = 0.2, 
      sector.index = sector.name, 
      track.index = 2)
  }, 
  bg.border = NA)


setwd("~/Desktop/Spring 2018/CIS 5270/Project 2/data")
View(drivers)
drivers<-read.csv('drivers.csv',sep=',',stringsAsFactors=F)
driversStandings<-read.csv('driverStandings.csv',sep=',',stringsAsFactors=F)
results <- read.csv('results.csv', sep = ',')
constructors<-read.csv('constructors.csv',sep=',',stringsAsFactors=F)

joined <- join(drivers, driversStandings, type = "inner")
joined2 <- sqldf("SELECT driverID, driverRef, wins FROM joined GROUP By driverRef")

joined3 <- sqldf("SELECT driverID, driverRef, wins, results.constructorID FROM joined2 JOIN results USING(driverID)")
joined3_1 <- sqldf("SELECT driverRef,wins,constructors.constructorref FROM joined3 JOIN constructors")
joined4 <- sqldf("SELECT * FROM joined3_1 GROUP BY driverRef, constructorRef")
joined5 <- sqldf("SELECT driverRef, constructorRef FROM joined4 WHERE constructorRef IN ('mclaren','ferrari','williams')")
#View(joined5)
df<- data.frame(joined5)

data1 <- sqldf("SELECT driverID, driverRef from drivers")
data2 <- sqldf("SELECT driverID, wins from driversStandings")
data3 <- sqldf("SELECT driverID, driverRef, COUNT(wins) AS Wins FROM data1 JOIN data2 USING(driverID) GROUP By driverRef")
data4 <- sqldf("SELECT * FROM data3 WHERE Wins > 100")
#View(data3)
ggplot(data4, aes(x = driverRef, y=Wins, fill=Wins) ) + geom_bar(width = .75,stat="identity")+coord_polar(theta = "x") 

