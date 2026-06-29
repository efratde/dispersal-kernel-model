library(ggplot2)
library(readr)

frag <- read_csv("mymodel - 200621_V2 experiment-table4.csv")
no_frag <- read_csv("mymodel - 200621_V2 experiment-table_1.csv")
data <- merge(frag, no_frag, all = T)
names(data)[1] <- 'Run_number'
names(data)[2] <- 'adaptation'
names(data)[4] <- 'pollination'
names(data)[5] <- 'trt'
names(data)[8] <- 'Step'
names(data)[9] <- 'Htz_25Q'
names(data)[10] <- 'Htz_50Q'
names(data)[11] <- 'Htz_75Q'
names(data)[12] <- 'disp_25Q'
names(data)[13] <- 'disp_50Q'
names(data)[14] <- 'disp_75Q'
names(data)[19] <- 'count_bins4'
names(data)[20] <- 'count_bins3'
names(data)[21] <- 'count_bins2'
names(data)[22] <- 'count_bins1'
names(data)[23] <- 'count_bins0'
data <- cbind(data, Total = rowSums(data[,19:23]))
data$trt <- as.factor(data$trt)
library(ggplot2)

ggplot(data) +
 aes(x = Step, y = fixation_p, colour = dist) +
 geom_point(size = 1L) +
 geom_smooth(span = 0.75) +
 scale_color_distiller(palette = "YlOrRd") +
 theme_minimal() +
 facet_grid(vars(adaptation), vars(trt))

ggplot(data) +
 aes(x = Step, y = Htz_50Q, colour = dist) +
 geom_point(size = 1L) +
 geom_smooth(span = 0.75) +
 scale_color_distiller(palette = "YlOrRd") +
 theme_minimal() +
 facet_grid(vars(adaptation), vars(trt))

ggplot(subset(data, adaptation == F)) +
 aes(x = Step, y = fixation_p, colour = trt) +
 geom_point(size = 1L) +
 geom_smooth(span = 0.75) +
 scale_color_brewer(palette = "YlOrRd") +
 theme_minimal() +
 facet_grid(vars(pollination), vars(dist))

data$`trt` <- as.factor(data$`trt`)

ggplot(data, aes(Step, fixation_p, color = interaction(trt, adaptation))) + geom_smooth(se = T, method = loess) +
  facet_grid(pollination ~ dist) + labs(x = "Seed dispersal distance", y = "Pollination distance")

ggplot(data, aes(Step, Htz_50Q, color = pollination)) + geom_point() + geom_smooth(se = T, method = loess) +
  facet_grid(adaptation ~ trt) + labs(x = "Time", y = "Median heterozygosity levels") +    
  scale_colour_gradient(low = 'yellow', high = 'red3')

ggplot(data, aes(Step, fixation_p, color = pollination)) + geom_point() + geom_smooth(se = T, method = loess) +
  facet_grid(adaptation ~ trt) + labs(x = "Time", y = "Fixation proportion") +    
  scale_colour_gradient(low = 'yellow', high = 'red3')

ggplot(data, aes(x = Var1, y = mean_SD , color = interaction(Var3, Var2)))+ geom_point(size = 3, aes(color = mean_intensity))+ 
  geom_line(lwd = 1.5, aes(color = mean_intensity))+    scale_colour_gradient(low = “yellow”, high = “red3”)
  
ggplot(subset(data, Step == 10), aes(x=dist, y=pollination) ) +
  stat_density_2d(aes(fill = fixation_p), geom = "polygon", contour = FALSE) +
  scale_x_continuous() +
  scale_y_continuous() +
  theme(
    legend.position='none'
  )


ggplot(data, aes(disp_50Q, Htz_50Q, z = fixation_p)) + stat_density_2d(aes(color = fixation_p)) 

m <- ggplot(subset(data, adaptation == F), aes(disp_50Q, Total, z = Total))
m <- m + geom_point()
m + geom_density_2d_filled(alpha = 0.5, aes(fill = fixation_p))

ggplot(data, aes(Step, disp_50Q)) + 
  geom_smooth()

ggplot(data, aes(Step, count_bins0)) + geom_smooth(color = "red") + 
  geom_smooth(aes(Step, count_bins1), color = "orange") + 
  geom_smooth(aes(Step, count_bins2), color = "yellow") + 
  geom_smooth(aes(Step, count_bins3), color = "green") +
  geom_smooth(aes(Step, count_bins4), color = "blue") +
  facet_grid(vars(adaptation), vars(trt))

