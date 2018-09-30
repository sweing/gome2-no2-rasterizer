source("./env.r")
source("./helpers.r")
source("./globals.r")
source("./auth.txt") #ADD YOUR LOGIN DATA HERE

requiredPackages = c("data.table")

if (javaInstalled)
    requiredPackages = c(requiredPackages, "xlsx")

loadPackages(requiredPackages)

