## Linear Regression Model

### Import the dataset
malay <- load("/Users/semih/malay.rdata")

### View the dataset
View(malay)

### Let's see the distribution of RTs
x <- malay$LDT_RT
h <- hist(x, col = "white", xlab = "Reaction Time (ms.)", ylim = c(0, 300),
          main="Histogram of Reaction Time")
xfit<-seq(min(x), max(x), length=40)
yfit<-dnorm(xfit, mean=mean(x), sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)

### Log transformation
malay$logRT <- log(malay$LDT_RT)

### Draw the histogram again
x <- malay$logRT
h <- hist(x, col = "white", xlab = "log(RT)", ylim = c(0,225),
          main="Histogram of Reaction Time (log)")
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)

### Draw the histogram for frequency
x <- malay$freq_malaysia.million
h <- hist(x, col = "white", xlab = "Frequency (in million)",
          main="Histogram of Frequency (in million)")
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)

### QQ Plot
qqnorm(malay$freq_malaysia.million, main='Normal Or Not?')
qqline(malay$freq_malaysia.million)

### Let's check log(frequency)
x <- malay$lg_freq_malaysia
h <- hist(x, col = "white", xlab = "log(Frequency)", ylim = c(0,175),
          main="Histogram of Frequency (log)")
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)

### QQ Plot (log)
qqnorm(malay$lg_freq_malaysia, main='Normal Or Not?')
qqline(malay$lg_freq_malaysia)

### Now plot the frequency by reaction time (log)
plot(malay$lg_freq_malaysia, exp(malay$logRT), xlab="Frequency (log)", ylab="Reaction Time (ms.)",
     main="Effect of Word Frequency on Lexical Decision", pch = 20)


### Now fit the model
lm1.1 <- lm(logRT ~ lg_freq_malaysia, data = malay)
summary(lm1.1)

### To check model fit
plot(lm1.1)

### See the predictions of the model
malay$predicted <- exp(predict(lm1.1))
malay$handpred <- exp(6.601223 + malay$lg_freq_malaysia*(-0.088424))
malay$handpred <- NULL

### Compare actual values with the predicted values
cor(x = malay$predicted, y = malay$LDT_RT, method = "pearson")

plot(x = malay$predicted, y = malay$LDT_RT, pch = 20,
     xlab = "Predicted Values",
     ylab = "Actual Values",
     main = "Actual vs. Predicted Values")
abline(a = 0, b = 1, col = "red", lwd = 3)
text(590, 970, labels = "Pearson Cor. = 0.41")


### Plot the fitted values on the observed data

### First, get the min and max values and apply model parameters on them
minf <- min(malay$lg_freq_malaysia)
maxf <- max(malay$lg_freq_malaysia)
minp <- exp(6.601223 + minf*(-0.088424))
maxp <- exp(6.601223 + maxf*(-0.088424))

### Second, plot them on the observed data
plot(malay$lg_freq_malaysia, exp(malay$logRT), xlab="Frequency (log)", ylab="Reaction Time (ms.)",
     main="Effect of Word Frequency on Lexical Decision RTs", pch = 20)
polygon(x = c(0.17, 0.17, 2.98, 2.98),
        y = c(723.0353, 726.9929, 563.5271, 567.4848), col = "pink", lwd = 3, border = NA)
#arrows(malay$lg_freq_malaysia, malay$low, malay$lg_freq_malaysia, malay$high, code = 3, angle = 180, col = "pink")
lines(x = c(minf, maxf), y = c(minp,  maxp), col = "red", lwd = 1)
# Increase the width of the line
lines(x = c(minf, maxf), y = c(minp,  maxp), col = "red", lwd = 3)


## Extending the model

### Standardize the data
malay$scaledON <- (malay$Orthographic.N - mean(malay$Orthographic.N))/sd(malay$Orthographic.N)
malay$scaledON <- scale(malay$Orthographic.N)

### Adding the orthographic neighborhood variable
lm1.2 <- lm(logRT ~ lg_freq_malaysia + scaledON, data = malay)
summary(lm1.2)

### Let's see the predictions
malay$predicted2 <- exp(predict(lm1.2))

cor(x = malay$predicted2, y = malay$LDT_RT, method = "pearson")

plot(x = malay$predicted2, y = malay$LDT_RT, pch = 20,
     xlab = "Predicted Values",
     ylab = "Actual Values",
     main = "Actual vs. Predicted Values")
abline(a=0, b=1, col = "red", lwd = 3)
text(550, 970, labels = "Pearson Cor. = 0.48")

### Adding the interaction term
lm1.3 <- lm(logRT ~ lg_freq_malaysia + scaledON + lg_freq_malaysia:scaledON, data = malay)
summary(lm1.3)

## Effect of word length

### Standardize the variable
malay$word_length <- scale(malay$Number.of.Letters)

lm1.4 <- lm(logRT ~ lg_freq_malaysia + scaledON + word_length, data = malay)
summary(lm1.4)


### Adding an interaction term

lm1.5 <- lm(logRT ~ lg_freq_malaysia + scaledON*word_length + lg_freq_malaysia:word_length, data = malay)
summary(lm1.5)


### Compare the models
AIC(lm1.1,lm1.2,lm1.3,lm1.4,lm1.5)
BIC(lm1.1,lm1.2,lm1.3,lm1.4,lm1.5)

## Fitting linear regression models with categorical variables

## Import the dataset
rc <- read.csv("~/Desktop/stat-workshop/datasets/rc.csv")

## View the dataset
View(rc)

## Let's see the distribution of RTs.
x <- rc$rawRT
h <- hist(x, col = "white", xlab = "log(RT)",
          main="Histogram of Reaction Time")
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)


### Without bars
plot(density(rc$rawRT), xlab="Reaction Time (ms.)", main = "Distribution of Reaction Time")


## It does not seem to be a normally distributed data
## due to the characteristics of RT data, so we normalize
## the data using log transformation.
rc$logRT <- log(rawRT)

## Now check the histogram
x <- rc$logRT
h <- hist(x, col = "white", xlab = "log(RT)",
          main="Histogram of Reaction Time (log)")
xfit<-seq(min(x),max(x),length=40)
yfit<-dnorm(xfit,mean=mean(x),sd=sd(x))
yfit <- yfit*diff(h$mids[1:2])*length(x)
lines(xfit, yfit, col="red", lwd=3)


## Without bars
plot(density(rc$logRT), xlab="log(RT)", main = "Distribution of log(RT)")

## Now visualize region_position and condition

### First we need to make some adjustments.
rc$ss <- 1 # Dummy variable for the number of observation in a condition

### Here we aggregate data to 
d1 <- aggregate(rawRT ~ condition + region_position, data = rc, FUN = mean)
d2 <- aggregate(rawRT ~ condition + region_position, data = rc, FUN = sd)
d3 <- aggregate(ss ~ condition + region_position, data = rc, FUN = sum)

### Bind the data
d <- cbind(d1, sd = d2$rawRT, ss = d3$ss)
rm(d1,d2,d3)

### Compute 95% CI
alpha = 0.05
d$ci <- qt(p=alpha/2, df=d$ss,lower.tail=F)*(d$sd/sqrt(d$ss))
d$Low <- d$rawRT - d$ci
d$High <- d$rawRT + d$ci

### Subset the data
subj <- subset(d, condition == "subjgap")
obj <- subset(d, condition == "objgap")

### Now plot!
plot(subj$region_position-0.05, subj$rawRT, type = "b", pch = 15, col= "red",
     xlim = c(1,6), ylim = c(300,500), xlab = "Region Position", ylab = "Reaction Time (ms.)",
     main = "Subject vs. Object Gap (RT)")
arrows(subj$region_position-0.05, subj$Low, subj$region_position-0.05, subj$High, length=0.05, angle=90, code=3, col = "red")
lines(obj$region_position+0.05, obj$rawRT, type = "b", pch = 16, col = "blue")
arrows(obj$region_position+0.05, obj$Low, obj$region_position+0.05, obj$High, length=0.05, angle=90, code=3, col = "blue")
legend("topright", legend=c("Subject Gap", "Object Gap"), col=c("red", "blue"), lty = 1, pch = c(15,16))


# CHECK LOG RT
d1 <- aggregate(logRT ~ condition + region_position, data = rc, FUN = mean)
d2 <- aggregate(logRT ~ condition + region_position, data = rc, FUN = sd)
d3 <- aggregate(ss ~ condition + region_position, data = rc, FUN = sum)

### Bind the data
d <- cbind(d1, sd = d2$logRT, ss = d3$ss)
rm(d1,d2,d3)

### Compute 95% CI
alpha = 0.05
d$ci <- qt(p=alpha/2, df=d$ss, lower.tail=F)*(d$sd/sqrt(d$ss))
d$Low <- exp(d$logRT - d$ci)
d$High <- exp(d$logRT + d$ci)

### Subset the data
subj <- subset(d, condition == "subjgap")
obj <- subset(d, condition == "objgap")

### Now plot!
plot(subj$region_position-0.05, exp(subj$logRT), type = "b", pch = 15, col= "red",
     xlim = c(1,6), ylim = c(300,400), xlab = "Region Position", ylab = "log(RT)",
     main = "Subject vs. Object Gap (log(RT))")
arrows(subj$region_position-0.05, subj$Low, subj$region_position-0.05, subj$High, length=0.05, angle=90, code=3, col = "red")
lines(obj$region_position+0.05, exp(obj$logRT), type = "b", pch = 16, col = "blue")
arrows(obj$region_position+0.05, obj$Low, obj$region_position+0.05, obj$High, length=0.05, angle=90, code=3, col = "blue")
legend("topright", legend=c("Subject Gap", "Object Gap"), col=c("red", "blue"), lty = 1, pch = c(15,16))


## Fitting the linear model

### Convert the variables into factor
rc$condition <- as.factor(rc$condition)
rc$region_position <-  as.factor(rc$region_position)
str(rc)

lm2.1 <- lm(logRT ~ condition, data = rc)
summary(lm2.1)

lm2.2 <- lm(logRT ~ condition + region_position, data = rc)
summary(lm2.2)

lm2.3 <- lm(logRT ~ condition*region_position, data = rc)
summary(lm2.3)

### Model Comparison
AIC(lm2.1, lm2.2, lm2.3)
BIC(lm2.1, lm2.2, lm2.3)

### Pairwise comparisons

#### Load the necessary package
install.packages("multcomp")
library(multcomp)

#### Comparison model
p.comp <- glht(lm2.2, linfct = mcp(region_position = "Tukey"))
summary(p.comp)




