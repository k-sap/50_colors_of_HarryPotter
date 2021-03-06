file <- "/media/ghost/shared/MiNI.Data_Science/3_semestr/TWD/p1/HP8_moods_info.csv"
library("png")

spectrum_drawer <- function(file){
  moods <- readRDS("moods.rda")
  read.csv(file, sep = ";") -> moods_info
  emotions <- rownames(moods)
  n <- length(moods_info[,1])
  result <- c()
  for (i in 1:n){
    result[i] <- which(emotions==moods_info[i, 1])
  }
  moods_spectrum <- moods[result, ]
  dim(moods_spectrum) <- c(1, dim(moods_spectrum)[1], 3)
  writePNG(moods_spectrum, "HP8_moods_spectrum.png")
}
spectrum_drawer(file)
