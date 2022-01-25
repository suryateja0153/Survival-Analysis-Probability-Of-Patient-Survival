#Author: Suryateja Chalapati

#Importing Libraries
library(readtext)
library(tidyverse)
library(survival)
library(survminer)
library(stargazer)

#Setting the Working Directory and Importing the Dataset
setwd("C:/Users/surya/Downloads")

lc <- read.table("LungCancer.txt", skip=15)
colnames(lc) <- c("treatment", "cell_type", "survival_days",	"status",	"karno_score",
                 "months_diag", "age_years", "pri_chemo")
attach(lc)

#NA Values Column-Wise & Setting Factors
sapply(lc, function(x) sum(is.na(x)))
str(lc)

cols <- c(1, 2, 4, 8)
lc[cols] <- lapply(lc[cols], factor)
str(lc)

#Data Visualizations and Feature Engineering
hist(lc$survival_days)
hist(lc$months_diag)
hist(lc$karno_score)
hist(lc$age_years)

hist(log(lc$survival_days))
hist(log(lc$months_diag))
hist(log(lc$karno_score))
hist(log(lc$age_years))

table(lc$status)
table(lc$treatment, lc$cell_type)
table(lc$cell_type, lc$pri_chemo)

lc$cell_type = ifelse(lc$cell_type == 2, "small cell", "non-small cell")

table(cell_type, pri_chemo)

#Non-Parametric Models
#Kaplan-Meier Model
y <- Surv(survival_days, status)
km1 <- survfit(y ~ treatment, data=lc)
summary(km1)

plot(km1, xlab="Time", ylab="Survival Probability")
ggsurvplot(km1, data = lc, risk.table = TRUE)

#For 365 Days
summary(km1, times=365)

#For 183 Days
summary(km1, times=183)

#Mean Survival Days
print(km1, print.mean=TRUE)

#Cox Proportional Hazard Model
cox1 <- coxph(y ~ treatment + cell_type + months_diag + age_years +
               pri_chemo + treatment*age_years + treatment*months_diag, data = lc, method="breslow")
summary(cox1)

#Parametric Models
#Exponential, Weibull, and log-logistic Models
exp1 <- survreg(y ~ treatment + cell_type + months_diag + age_years +
                 pri_chemo + treatment*age_years + treatment*months_diag, data = lc, dist="exponential")

wbl1 <- survreg(y ~ treatment + cell_type + months_diag + age_years + 
                 pri_chemo + treatment*age_years + treatment*months_diag, data = lc, dist="weibull")

llg1 <- survreg(y ~ treatment + cell_type + months_diag + age_years + 
                 pri_chemo + treatment*age_years + treatment*months_diag, data = lc, dist="loglogistic")

#Stargazer
stargazer(cox1, exp1, wbl1, llg1, type="text", single.row=TRUE)
