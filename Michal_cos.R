library("png")
library(ggplot2)
library(zoo)

difference <- function(x){
  #Liczy normę w R^3 między obecnym i poprzednim obrazkiem dla listy plików png
  prev <- readPNG(x[1])
  dim(prev) <- c(dim(prev)[1] * dim(prev)[2], dim(prev)[3])
  
  dist <- rep(0, times=(length(x)-1))
  
  for(i in 2:length(x)){
    cur <- readPNG(x[i])
    dim(cur) <- c(dim(cur)[1] * dim(cur)[2], dim(cur)[3])
    diff <- prev-cur
    dist[i-1] <- sum(abs(diff))
    prev <- cur
  }
  
  return(dist)
}

#Średnia ruchoma
rm <- rollmean(out, 200)

df <- data.frame(value = rm, x = 1:length(rm))
ggplot(df, aes(x=x, y=value)) + geom_point()