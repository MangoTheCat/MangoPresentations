# ---
# title: "Working with databases"
# author: "Steph Locke"
# date: "30/11/2015"
# type: "Exercise answers"
# ---

# Exercise 1 ----
library(RSQLite)
myDB <- dbConnect(SQLite(),"local.db")
dbListTables(myDB)

# Exercise 2 ----
dbWriteTable(myDB,"iris",iris)
dbReadTable(myDB,"iris")[1,]

# Exercise 3 ----
dbGetQuery(myDB,"SELECT `Sepal.Length`,
           `Sepal.Width` from iris ")[1,]

# Exercise 4 ----
dbGetQuery(myDB,"UPDATE iris
           SET species='Versicolour'
           WHERE species='versicolor'
           ")
dbGetQuery(myDB
           , "select * from iris where species='Versicolour'")[1:5,]

# Exercise 5 ----
dbGetQuery(myDB
           ,"delete from iris where `Sepal.Length`<=4.5")

# Exercise 6 ----
library(data.table)
irisDT <- rbind(data.table(iris)[,.(Count = .N),by = Species],
                data.table(Species = 'Unknown', Count = 50))
irisDT

library(dplyr)
mydplyrtbl <- as.data.frame(rbind(
  iris %>% group_by(Species)
  %>% summarise(count = length(Species))
  , data.frame(Species = "Unknown", count = 50)
))
mydplyrtbl

# Exercise 7 ----
dbWriteTable(myDB,"irisDT",irisDT)
dbListTables(myDB)

# Exercise 8 ----
dbGetQuery(myDB,"SELECT i.*, l.Count from iris i
           inner join irisDT l on i.Species=l.Species") %>%
  group_by(Species) %>%
  summarise(count = length(Species))

dbGetQuery(myDB,"SELECT l.*, i.`Sepal.Length` from irisDT l
           left join iris i  on i.Species=l.Species") %>%
  group_by(Species) %>%
  summarise(count = sum(is.na(Sepal.Length)))

# Exercise 9 ----
dbGetQuery(
  myDB,"select * from iris
  where `Sepal.Length`*`Sepal.Width`<=10
  and `Petal.Length`*`Petal.Width`>=3 "
)

# Exercise 10 ----
dbGetQuery(
  myDB,"select Species,
  avg(`Petal.Length`)  as Length,
  avg(`Petal.Width`)  as Width
  from iris group by Species"
)

# Exercise 11 ----
dbGetQuery(myDB,"select *
           from iris
           order by `Petal.Width`*`Petal.Length` DESC")

# Exercise 12 ----
dbWriteTable(myDB,"iris",iris,overwrite = TRUE)

# Exercise 13 ----
dbRemoveTable(myDB,"iris")

# Tangents ----
test <- dbSendQuery(myDB
                    ,"delete from iris where `Sepal.Length`<=4.5")
dbGetRowsAffected(test)
