library(readr)
summary(data)

library(tidyr)
library(ggplot2)
data <- read.csv("big-experiment-1-of-5multi 31X31.csv", stringsAsFactors=TRUE)


summary(data)

data_long <- pivot_longer(data, 8:31 , names_to = "trt", values_to = "count")
data_long2 <- pivot_longer(data, 32:55 , names_to = "trt", values_to = "dispersal")
data_long3 <- pivot_longer(data, 56:79 , names_to = "trt", values_to = "htz")
data_long_merged <- cbind(data_long[,1:7], data_long$trt, data_long$count, data_long2$dispersal, data_long3$htz)
summary(data_long_merged)
data2 <- data_long_merged
data2[1:8] <- lapply(data2[1:8], as.factor)
summary(data2)

write.csv(data2, "R/Netlogo/new.csv")
         levels(data2$`data_long$trt`)
         

data <- read.csv("R/Netlogo/new.csv", stringsAsFactors=TRUE)
data[1:8] <- lapply(data[1:8], as.factor)

summary(data)

disp1 <- subset(data, dispersal.strategy == "1")
disp2 <- subset(data, dispersal.strategy == "2")
coupled <- subset(disp2, Coupled == "TRUE")
ggplot(subset(coupled, bins == "all" & rd != "all")) + aes(x = step, y =  N, color = rd ) + 
  geom_point() + facet_grid(vars(htz), vars(autocorrelation))


cont_data <- continuous.table <- read.csv("120721/continuous table.csv", stringsAsFactors=TRUE)
summary(cont_data)

cont_data_long <- pivot_longer(cont_data, 5:28 , names_to = "trt", values_to = "count")
cont_data_long2 <- pivot_longer(cont_data, 29:52 , names_to = "trt", values_to = "dispersal")
cont_data_long3 <- pivot_longer(cont_data, 53:76 , names_to = "trt", values_to = "htz")
cont_data_long_merged <- cbind(cont_data_long[,1:4], cont_data_long$trt, cont_data_long$count, cont_data_long2$dispersal, cont_data_long3$htz)
summary(cont_data_long_merged)
data3 <- cont_data_long_merged
data3[1:3] <- lapply(data3[1:3], as.factor)
summary(data3)
data3[5] <- lapply(data3[5], as.factor)

write.csv(data3, "R/Netlogo/cont.csv")

data4 <- read.csv("R/Netlogo/cont.csv", stringsAsFactors=TRUE)
summary(data4)

disp2_cont <- subset(data4, dispersal.strategy == 2)
summary(disp2_cont)
cont_all <- subset(disp2_cont, bins == "all" & rd != "all")
summary(cont_all)
ggplot(cont_all) + aes(x = step, y =  N, color = rd ) + 
  geom_point() + facet_grid(vars(Coupled))

ggplot(subset(adap3, bins == "all" & rd != "all")) + aes(x = step, y =  N, color = rd ) + 
  geom_point() + facet_grid( vars(Coupled), vars(autocorrelation))

ggplot(subset(adap3, bins != "all" & rd != "all" & Coupled = "TRUE")) + aes(x = step, y =  N, color = bins ) + 
  geom_point() + facet_grid( vars(rd), vars(autocorrelation))

adap <- subset(disp2_cont, select = -c(7:9))
adap <- cbind(adap, disp2_cont[7:9])
adap <- subset(adap, select = -c(6))

adap2 <- tibble::add_column(adap, autocorrelation = 1:1, .after = "Coupled")
adap2[6:7] <- lapply(adap2[6:7], as.factor)
adap3 <- rbind(disp2, adap2)
summary(adap3)
colnames(disp2) <- colnames(adap2)
adap2[1:5] <- as.factor(adap2[1:5])
adap$step <- as.numeric(adap$step)

data_new <- read.csv("120721/autocorrelation2_8 table.csv", stringsAsFactors=TRUE)
summary(data_new)
new2 <- pivot_longer(data_new, 7:30 , names_to = "trt", values_to = "count")
new3 <- pivot_longer(data_new, 31:54 , names_to = "trt", values_to = "dispersal")
new4 <- pivot_longer(data_new, 55:78 , names_to = "trt", values_to = "htz")
summary(data2_long3)
data2_long_merged <- cbind(data_new[,1:6], new2$trt, new2$count, new3$dispersal, new4$htz)
summary(data_b)
data_b <- data2_long_merged
data_b[1:5] <- lapply(data_b[1:5], as.factor)
summary(data_b)
data_b$step <- as.numeric(data_b$step)
data_b <- subset(data_b, select = -c(8))
write.csv(data5, "R/Netlogo/r_big_data.csv")
levels(data2$`data_long$trt`)

ac <- read.csv("R/Netlogo/new3.csv", stringsAsFactors = TRUE)
summary(ac)
ac[1:5] <- lapply(ac[1:5], as.factor)

x <- subset(ac, bins == "all" & rd != "all" & dispersal.strategy == 2)
summary(x)
ggplot(data) + aes(x = step, y = N, color = rd ) +
  geom_point() + facet_grid( vars(coupled), vars(autocorrelation))


data5[] <- lapply(data5, function(x) if(is.factor(x)) factor(x) else x)

data <- read.csv("R/Netlogo/r_big_data.csv", stringsAsFactors = TRUE)
summary(data)
data <- subset(data, select = -c(1))
data$step <- as.numeric(data$step)

df <- as.data.frame(data)

write.csv(x3, "combined.csv")

lapply(myfiles, function(x) lapply(x, function(x), )
