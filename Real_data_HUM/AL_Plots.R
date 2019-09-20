rm(list=ls())

which_method <- 2 # 1= STEPDOWN , 2 = RMPSSP
which_algo <-  2 # 1 = EHUM, 2 = ULBA


setwd("~/RMPS/Real_data_HUM")
file <- paste0("AL_MATLAB.csv")
DATA <- read.csv(file, header = F)


var_names <- c("FACTOR1", "ktemp", "kpar", "kfront", "zpsy004", "zpsy005", "zpsy006",
               "zinfo", "zbentc", "zbentd", "zboston","zmentcon",	"zworflu",	"zassc")

var_names_required <- c("ktemp", "kpar", "kfront", "zpsy005", "zpsy006",
               "zinfo", "zbentc", "zbentd", "zboston","zmentcon",	"zworflu",	"zassc")

DATA_arranged <- cbind(t(DATA[which(DATA[,1] == 0),]),t(DATA[which(DATA[,1] == 1),]))
DATA_arranged <- cbind(DATA_arranged, t(DATA[which(DATA[,1] == 2),]))


sample_sizes <- c(length(which(DATA[,1] == 0)), length(which(DATA[,1] == 1)), length(which(DATA[,1] == 2)))

X_mat <- DATA_arranged[-1,]
X_mat <- X_mat[-c(1,5),]


if(which_method == 1)
{if(which_algo == 1)
{filename <- paste0("AL_EHUM_STEPDOWN.csv")
plot_name <- paste0("PLOTS_EHUM_STEPDOWN.jpg")
vect <- read.csv(filename, header = F)
beta <-  vect[3:14,]}
  if(which_algo == 2)
  {filename <- paste0("AL_ULBA_STEPDOWN.csv")
  plot_name <- paste0("PLOTS_ULBA_STEPDOWN.jpg")
  vect <- read.csv(filename, header = F)
  beta <-  vect[3:14,]}
}

if(which_method == 2)
{if(which_algo == 1)
{filename <- paste0("AL_EHUM_RMPS.csv")
plot_name <- paste0("PLOTS_EHUM_RMPS.jpg")
vect <- read.csv(filename, header = F)
beta <-  vect[3:14,]}
  if(which_algo == 2)
  {filename <- paste0("AL_ULBA_RMPS.csv")
  plot_name <- paste0("PLOTS_ULBA_RMPS.jpg")
  vect <- read.csv(filename, header = F)
  beta <-  vect[3:14,]}
}



beta <- as.array(beta)
beta <- beta/norm(as.matrix(beta))


projection <- beta%*%X_mat

X_0 <- projection[1:sample_sizes[1]]
X_1 <- projection[(sample_sizes[1]+1):(sample_sizes[1]+sample_sizes[2])]
X_2 <- projection[(sample_sizes[1]+sample_sizes[2]+1):(sample_sizes[1]+sample_sizes[2]+sample_sizes[3])]


########### Youden Index ######################################
t_minus_range_up <- median(X_1)
t_minus_range_down <- median(X_0)

t_plus_range_up <- median(X_2)
t_plus_range_down <- median(X_1)

youden <- function(X_0, X_1, X_2, t_minus, t_plus)
{F_minus_t_minus <- length(which(X_0 < t_minus))/length(X_0)
F_zero_t_minus <- length(which(X_1 < t_minus))/length(X_1)
F_zero_t_plus <- length(which(X_1 < t_plus))/length(X_1)
F_plus_t_plus <- length(which(X_2 < t_plus))/length(X_2)
youden_val <- 0.5*(F_minus_t_minus - F_zero_t_minus + F_zero_t_plus - F_plus_t_plus)
return(youden_val)}

possibles_1 <- seq(from = t_minus_range_down, to = t_minus_range_up, by = (t_minus_range_up - t_minus_range_down)/1000)
possibles_2 <- seq(from = t_plus_range_down, to = t_plus_range_up, by = (t_plus_range_up - t_plus_range_down)/1000)

youdens <- matrix(0, length(possibles_1), length(possibles_2))

for(ii in 1:length(possibles_1))
{for(jj in 1:length(possibles_2))
{t_minus <- possibles_1[ii]
t_plus <- possibles_2[jj]
youdens[ii,jj] <- youden(X_0, X_1, X_2, t_minus, t_plus)}}

indices <- which(youdens == max(youdens), arr.ind = TRUE)
indices <- indices[1,]
youdens[indices[1], indices[2]]
c(possibles_1[indices[1]], possibles_2[indices[2]])
c(mean(X_0),mean(X_1), mean(X_2))

yi <- round(youdens[indices[1], indices[2]]*1000)/1000
ehum <- -round(vect[1,]*1000)/1000
############################################################### 
jpeg(plot_name)
boxplot(X_0, X_1, X_2, names=c("Healthy ", "MCI", "AD"), #main="Car Milage Data", 
        xlab="Disease Categories", ylab ="Score")
abline(h=possibles_1[indices[1]],lwd=1, lty=2)
abline(h=possibles_2[indices[2]],lwd=1, lty=2)
#text(1,2, paste0("YI =", yi),cex = 1.2)
dev.off()

# MATRIX_YI <- matrix(0,3,3)
# write.table(MATRIX_YI, "MATRIX_YI.csv", row.names = FALSE, col.names = FALSE, sep = ",")
# 
# MATRIX_EHUM <- matrix(0,3,3)
# write.table(MATRIX_EHUM, "MATRIX_EHUM.csv", row.names = FALSE, col.names = FALSE, sep = ",")

MATRIX_YI <- read.csv("MATRIX_YI.csv", header = F)
MATRIX_YI[which_method,which_algo] <- yi
write.table(MATRIX_YI, "MATRIX_YI.csv", row.names = FALSE, col.names = FALSE, sep = ",") 

MATRIX_EHUM <- read.csv("MATRIX_EHUM.csv", header = F)
MATRIX_EHUM[which_method,which_algo] <- ehum
write.table(MATRIX_EHUM, "MATRIX_EHUM.csv", row.names = FALSE, col.names = FALSE, sep = ",") 

