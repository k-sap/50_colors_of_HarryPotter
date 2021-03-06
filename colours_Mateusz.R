library("png")

hsv2rgb <- function(p) {
  # lepiej nie pytac, hsv2rgb przyjmuje wektor p z punktem w hsv i zwraca wektor w rgb
  h <- 360*p[1]
  C <- p[3]*p[2]
  X <- C*(1-abs((h/60)%%2-1))
  m <- p[3]-C
  if (h<60) {p <- c(C,X,0)}
  else if (h<120) {p <- c(X,C,0)}
  else if (h<180) {p <- c(0,C,X)}
  else if (h<240) {p <- c(0,X,C)}
  else if (h<300) {p <- c(X,0,C)}
  else {p <- c(C,0,X)}
  return(p+m)
}

frame2point <- function(f) {
  # odczytaj plik f
  picture <- readPNG(f)
  # redukcja wymiarow na potrzeby rgb2hsv
  dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
  picture <- t(rgb2hsv(t(picture), maxColorValue=1))
  # wyznaczanie centrow
  if (nrow(unique(picture, MARGIN=1)) > 35) {
    picture <- kmeans(picture, centers=35, iter.max=10)
    # wyznaczanie najpopularniejszego punktu
    point <- picture$centers[which.max(picture$size), ]
  }
  else {
    point <- picture[1,]
  }
  
  # konwersja do rgb
  point <- hsv2rgb(point)
  return(point)
}

#files <- c("HP5/HPZF00001.png",
#           paste("HP5/HPZF00", seq(from=101, to=981, by=100), ".png", sep=""),
#           paste("HP5/HPZF0", seq(from=1001, to=9981, by=100), ".png", sep=""),
#           paste("HP5/HPZF", seq(from=10001, to=198561, by=100), ".png", sep=""))
#sequence <- rbind(sapply(files, FUN=frame2point))
#dim(sequence) <- c(1, dim(sequence)[2], 3)
#writePNG(sequence, "HP5.png")

calculate <- function(dir, dir_output){
  files <- list.files(dir)
  files <- paste(dir, files, sep = "")
  sequence <- rbind(sapply(files, FUN=frame2point))
  dim(sequence) <- c(1, dim(sequence)[2], 3)
  writePNG(sequence, paste(dir_output, "HP_spectrum.png", sep = ""))
}