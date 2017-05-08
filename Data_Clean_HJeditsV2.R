## -------------------------------------------------------------------------------
##
## CAAT Pension Analytics
##
## -------------------------------------------------------------------------------



# HJ: General Comments
#   (i)   It's good to split your analysis into different scripts. For example, this started as a Data Cleansing
#         script and now it has a regression piece at the end. You can start a new script, and run this script
#         at the start of the new script using the source() function. 
#         I didn't bother for this one because it's only 1 extra section. But the Munich project ended having 50+ scripts
#         so I used source() quite a bit. 
#         Just a good habit to get in to
#   (ii)  R-squared isn't the greatest measure of fit. Adjusted R-squared is a little better so we can use it for 
#         this analysis. Generally speaking you use these measures of fit when you can compare it to something.
#         I don't believe in saying "a model must have R-squared > 0.80 to be considered good" because it completely
#         depends on context. We could use a version of R-squared if we were doing a cross-validation exercise, or
#         if we had results from last year to compare to. But since we don't have any context, it is difficult to 
#         draw the conclusion that R-squared isn't high enough right now.



# HJ: if you are starting a script fresh, it is good to start with this line
rm(list = ls())


library(dplyr)
library(WriteXLS)

##Removes unwanted columns for 2016, based this off PreProcessing Script
Active16 <- Active16[c('Member.Key', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan')]
Retired16 <- Retired16[c('MKEY', 'MBIRTH', 'MSEX', 'RETDATE')]
Deferred16 <- Deferred16[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
DeferredBOBW16 <- DeferredBOBW16[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
DeferredNonBOBW16 <- DeferredNonBOBW16[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
Terminated16 <- Terminated16[c('Member.Key', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]


##Removes unwanted columns for 2015, based this off PreProcessing Script
Active15 <- Active15[c('Member.Key', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan')]
Deferred15 <- Deferred15[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
DeferredBOBW15 <- DeferredBOBW15[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
DeferredNonBOBW15 <- DeferredNonBOBW15[c('Mkey', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]
Terminated15 <- Terminated15[c('Member.Key', 'Birth.Date', 'Employment.Date', 'Gender', 'Date.Joined.Plan', 'Termination.Date')]

##Renames the columns so the names are consistent across all dataframes
names(Active16) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan')
names(Active15) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan')
names(Retired16) <- c('MemberKey', 'DateOfBirth_Member', 'Gender_Member', 'YearOfRetirement')
names(Deferred16) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(Deferred15) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(DeferredBOBW16) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(DeferredBOBW15) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(DeferredNonBOBW16) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(DeferredNonBOBW15) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 'YearOfTermination')
names(Terminated16) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 
                       'YearOfTermination')
names(Terminated15) <- c('MemberKey', 'DateOfBirth_Member', 'DateOfEmployment', 'Gender_Member', 'DateJoinedPlan', 
                         'YearOfTermination')

#Add missing columns to dataframes so that each dataframe has the same number of columns
Active16$YearOfTermination <- NA
Active16$YearOfRetirement <- NA
Active16$Status <- "Active"

Active15$YearOfTermination <- NA
Active15$YearOfRetirement <- NA
Active15$Status <- "Active"

Deferred16$YearOfRetirement <- NA
Deferred16$Status <- "Deferred"

Deferred15$YearOfRetirement <- NA
Deferred15$Status <- "Deferred"

DeferredBOBW16$YearOfRetirement <- NA
DeferredBOBW16$Status <- "Deferred BOBW"

DeferredBOBW15$YearOfRetirement <- NA
DeferredBOBW15$Status <- "Deferred BOBW"

DeferredNonBOBW16$YearOfRetirement <- NA
DeferredNonBOBW16$Status <- "Deferred Non-BOWB"

DeferredNonBOBW15$YearOfRetirement <- NA
DeferredNonBOBW15$Status <- "Deferred Non-BOWB"

Terminated16$YearOfRetirement <- NA
Terminated16$Status <- "Terminated"

Terminated15$YearOfRetirement <- NA
Terminated15$Status <- "Terminated"

Retired16$DateOfEmployment <- NA
Retired16$DateJoinedPlan <- NA
Retired16$YearOfTermination <- NA
Retired16$Status <- "Retired"

# Convert formats of the dates for 2016 files
Active16$DateOfBirth_Member <- as.Date(Active16$DateOfBirth_Member, format = '%m/%d/%Y')
Deferred16$DateOfBirth_Member <- as.Date(Deferred16$DateOfBirth_Member)
DeferredBOBW16$DateOfBirth_Member <- as.Date(DeferredBOBW16$DateOfBirth_Member, format = '%m/%d/%Y')
DeferredNonBOBW16$DateOfBirth_Member <- as.Date(DeferredNonBOBW16$DateOfBirth_Member, format = '%m/%d/%Y')
Terminated16$DateOfBirth_Member <- as.Date(Terminated16$DateOfBirth_Member, format = '%m/%d/%Y')
Retired16$DateOfBirth_Member <- as.Date(Retired16$DateOfBirth_Member)


# attempt to find some of the DateJoinedPlan dates for the retired members in 2016 data
# Retired16 <- left_join(Retired16, Active15[c('MemberKey', 'DateJoinedPlan', 'DateOfBirth_Member')], by = 'MemberKey')

#Resets the column order of the dataframes
Active16 <- Active16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Active15 <- Active15[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Deferred16 <- Deferred16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Deferred15 <- Deferred15[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
DeferredBOBW16 <- DeferredBOBW16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
DeferredBOBW15 <- DeferredBOBW15[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
DeferredNonBOBW16 <- DeferredNonBOBW16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
DeferredNonBOBW15 <- DeferredNonBOBW15[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Terminated16 <- Terminated16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Terminated15 <- Terminated15[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]
Retired16 <- Retired16[c('MemberKey', 'DateOfBirth_Member','Gender_Member', 'DateOfEmployment', 'DateJoinedPlan', 'YearOfTermination', 'YearOfRetirement', 'Status')]

#changes format of Termination/Retirement dates to include Year only
Retired16$YearOfRetirement = format(as.Date(Retired16$YearOfRetirement, format = "%Y-%m-%d"), "%Y")
Terminated16$YearOfTermination = format(as.Date(Terminated16$YearOfTermination, format = "%m/%d/%Y"), "%Y")
Terminated15$YearOfTermination = format(as.Date(Terminated15$YearOfTermination, format = "%m/%d/%Y"), "%Y")
Deferred16$YearOfTermination = format(as.Date(Deferred16$YearOfTermination, format = "%Y-%m-%d"), "%Y")
Deferred15$YearOfTermination = format(as.Date(Deferred15$YearOfTermination, format = "%m/%d/%Y"), "%Y")
DeferredBOBW16$YearOfTermination = format(as.Date(DeferredBOBW16$YearOfTermination, format = "%m/%d/%Y"), "%Y")
DeferredBOBW15$YearOfTermination = format(as.Date(DeferredBOBW15$YearOfTermination, format = "%m/%d/%Y"), "%Y")
DeferredNonBOBW16$YearOfTermination = format(as.Date(DeferredNonBOBW16$YearOfTermination, format = "%m/%d/%Y"), "%Y")
DeferredNonBOBW15$YearOfTermination = format(as.Date(DeferredNonBOBW15$YearOfTermination, format = "%m/%d/%Y"), "%Y")

#Removes membets with a year of termination/retirment <2015
Deferred16 <- subset(Deferred16,  YearOfTermination >= 2015)
Deferred15 <- subset(Deferred15, YearOfTermination >= 2015)
DeferredBOBW16 <- subset(DeferredBOBW16, YearOfTermination >= 2015)
DeferredBOBW15 <- subset(DeferredBOBW15, YearOfTermination >= 2015)
DeferredNonBOBW16 <- subset(DeferredNonBOBW16, YearOfTermination >= 2015)
DeferredNonBOBW15 <- subset(DeferredNonBOBW15, YearOfTermination >= 2015)
Terminated16 <- subset(Terminated16, YearOfTermination >= 2015)
Terminated15 <- subset(Terminated15, YearOfTermination >= 2015)
Retired16 <- subset(Retired16, YearOfRetirement >= 2015)

#appends the dataframes together as one database for year 2015 and 2016
Member_data_2016 <- rbind(Active16, Deferred16, DeferredBOBW16, DeferredNonBOBW16, Terminated16, Retired16)
Member_data_2015 <- rbind(Active15, Deferred15, DeferredBOBW15, DeferredNonBOBW15, Terminated15)

rownames(Member_data_2016) <- NULL
rownames(Member_data_2015) <- NULL

# HJ: not sure if you wanted this to store back into Member_data_2016 and Member_data_2015
# HJ: all that's happening here is printing the results
#orders dataframes by MemberKey
Member_data_2016[order(Member_data_2016$MemberKey),]
Member_data_2015[order(Member_data_2015$MemberKey),]

#Checks if members changed status between 2015 and 2016, couldn't find anything here
Active_Retired <- merge(Active15, Retired16, by.x = "MemberKey", by.y = "MemberKey")
Active_Deferred <- merge(Active15, Deferred16, by.x = "MemberKey", by.y = "MemberKey")
Active_DeferredBOBW <- merge(Active15, DeferredBOBW16, by.x = "MemberKey", by.y = "MemberKey")
Active_DeferredNonBOBW <- merge(Active15, DeferredNonBOBW16, by.x = "MemberKey", by.y = "MemberKey")
Deferred_Retired <- merge(Deferred15, Retired16, by.x = "MemberKey", by.y = "MemberKey")
DeferredBOBW_Retired <- merge(DeferredBOBW15, Retired16, by.x = "MemberKey", by.y = "MemberKey")
DeferredNonBOBW_Retired <- merge(DeferredNonBOBW15, Retired16, by.x = "MemberKey", by.y = "MemberKey")

# HJ: adding a few columns
Member_data_2016$YearsOfService <- floor(as.numeric(as.Date('2016-01-01') - as.Date(Member_data_2016$DateJoinedPlan, format = '%m/%d/%Y')) / 365.25)
Member_data_2016$MemberAge <- floor(as.numeric(as.Date('2016-01-01') - as.Date(Member_data_2016$DateOfBirth_Member)) / 365.25)

  
  

# HJ: commented out for now; one export is enough
##couldn't get XLS to work
# write.csv(Member_data_2016, file = "Q:/GTAActuarial/Retirement Actuarial Services/Clients/CAAT (Pension Plan)/2016 Annual Audit/Analytics/2016/Clean/MemberData2016.csv", row.names = FALSE)
# write.csv(Member_data_2015, file = "Q:/GTAActuarial/Retirement Actuarial Services/Clients/CAAT (Pension Plan)/2016 Annual Audit/Analytics/2015/Clean/MemberData2015.csv", row.names = FALSE)
# 



## Regression Analysis -----------------------------------------------------------------------------

# HJ: it looks like you were controlling for the NAs in the IF statement, after the fact
#     I just made the change in this line and commented out the future change (not sure it was working as I was still seeing NAs)

# HJ: also, don't overwrite the column YearOfTermination
#     remember that when you are producing NEW INFORMATION, always create either a new object, or a new column

# Shayan's Code ------
# Member_data_2016$YearOfTermination <- dplyr::if_else(Member_data_2016$YearOfTermination == 2015, 1, 0)
# Member_data_2016$YearOfRetirement <- dplyr::if_else(Member_data_2016$YearOfRetirement == 2015, 1, 0)
#
# Harry's Code ------
Member_data_2016$TerminatedIn2015 <- dplyr::if_else(is.na(Member_data_2016$YearOfTermination), 0, 
                                                     dplyr::if_else(Member_data_2016$YearOfTermination == 2015, 1, 0))
Member_data_2016$RetiredIn2015 <- dplyr::if_else(is.na(Member_data_2016$YearOfRetirement), 0, 
                                                    dplyr::if_else(Member_data_2016$YearOfRetirement == 2015, 1, 0))


# HJ: these have already been calculated; so I commented them out
# Member_data_2016$MemberAge <- as.numeric(as.Date("2016-01-01") - as.Date(Member_data_2016$DateOfBirth_Member)) / 365.25
# Member_data_2016$YearsOfService <- as.numeric(as.Date("2016-01-01") - as.Date(Member_data_2016$DateJoinedPlan)) / 365.25

# Member_data_2016[c('YearOfTermination', 'YearOfRetirement')][is.na(Member_data_2016[c('YearOfTermination', 'YearOfRetirement')])] <- 0

# HJ: none of these were included in the regression formula
#     but you actually didn't need to transform (but nothing wrong with doing it)
# Member_data_2016$Male <- dplyr::if_else(Member_data_2016$Gender_Member == 'M', 1, 0)
# Member_data_2016$Female <- dplyr::if_else(Member_data_2016$Gender_Member == 'F', 1, 0)
# Member_data_2016$Gender_Member <- dplyr::if_else(Member_data_2016$Gender_Member == 'M', 1, 0)

# names(Member_data_2016)[names(Member_data_2016) == "YearOfTermination"] <- "Termination"
# names(Member_data_2016)[names(Member_data_2016) == "YearOfRetirement"] <- "Retirement"

Member_data_2016$RetirementAgeGroup <- cut(Member_data_2016$MemberAge, c(18,50,55,60,65,69,70,71))
Member_data_2016$TerminationAgeGroup <- cut(Member_data_2016$MemberAge, c(18,20,25,30,35,40,45,50,55,60,65,70))

# HJ: changed the formula to include Gender
# HJ: name of the object is 'regret' LOL
regret <- lm(RetiredIn2015 ~ Gender_Member + RetirementAgeGroup, data = Member_data_2016)
regterm <- lm(TerminatedIn2015  ~ Gender_Member + TerminationAgeGroup, data = Member_data_2016)

# HJ: summary() is good enough for our purposes
summary(regret)
summary(regterm)

# HJ: export the coefficients/p-values



# # Other useful functions 
# coefficients(fit) # model coefficients
# confint(fit, level = 0.95) # CIs for model parameters 
# fitted(fit) # predicted values
# residuals(fit) # residuals
# anova(fit) # anova table 
# vcov(fit) # covariance matrix for model parameters 
# influence(fit) # regression diagnostics
# 
# coefficients(regret) # model coefficients
# confint(regret, level=0.95) # CIs for model parameters 
# regretted(regret) # predicted values
# residuals(regret) # residuals
# anova(regret) # anova table 
# vcov(regret) # covariance matrix for model parameters 
# influence(regret) # regression diagnostics
# 
# # Multiple Linear Regression Example 
# regterm <- lm(y ~ x1 + x2 + x3, data=mydata)
# summary(regterm) # show results
