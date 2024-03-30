install.packages("fastLink")
install.packages("haven")
library(fastLink)


path = "D:/Research/patent/data/uspto/unique_or_name.dta"
dfA = haven::read_dta(path)
df =dfA[1:2000,]


## Run fastLink

fl_out_dedupe <- fastLink(
  dfA = df, dfB = df,
  varnames = c("or_name_clean"),
  stringdist.match = c("or_name_clean"),
  partial.match = c("or_name_clean"),
  estimate.only = TRUE
)


## Apply to the whole dataset
fs.out <- fastLink(
  dfA = df, dfB = df,
  varnames = c("or_name_clean"),
  stringdist.match = c("or_name_clean"),
  partial.match = c("or_name_clean"),
  em.obj = fl_out_dedupe
)


dfA_dedupe <- getMatches(dfA = df, dfB = df, fl.out = fl_out_dedupe)
## Look at the IDs of the duplicates
names(table(dfA_dedupe$dedupe.ids)[table(dfA_dedupe$dedupe.ids) > 1])

dfA_dedupe11 <- getMatches(dfA = df, dfB = df, fl.out = fs.out)
## Look at the IDs of the duplicates
names(table(dfA_dedupe11$dedupe.ids)[table(dfA_dedupe11$dedupe.ids) > 1])
