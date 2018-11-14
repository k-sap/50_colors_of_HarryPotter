library(genie)
library(class)
library(zoo)

#picture <- readPNG(file)
#dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
#genie::hclust2(objects = picture, thresholdGini = 0.05) -> x
#k <- 7
#cutree(x, 7) -> y
library("png")

moods_info <- function(file){
  picture <- readPNG(file)
  dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])

  genie::hclust2(objects = picture_hsv) -> genie_clust
  k <- 7 #liczba kolorow do nastroju
  cutree(genie_clust, k) -> screenshots_classes
  mean_color_old(picture, clusters = screenshots_classes) -> mean_colors
  scene_moods(mean_colors = mean_colors) -> scene_moods
  as.character(scene_moods) -> scene_moods
  scene_moods[screenshots_classes] -> moods_info
  return(moods_info)
}

scene_moods <- function(mean_colors){
  moods <- readRDS("moods.rda")
  knn(test = mean_colors, train = moods, rownames(moods))
}

mean_color <- function(picture, clusters){
  k <- length(unique(clusters))
  mean_colors <- matrix(ncol = 3, nrow = k)
  for(i in 1:k){
    picture[clusters==i, ]-> tmp
    tmp[1, ] -> mean_colors[i, ]
  }
  return(mean_colors)
}
mean_color_old <- function(picture, clusters){
  k <- length(unique(clusters))
  mean_colors <- matrix(ncol = 3, nrow = k)
  for(i in 1:k){
    picture[clusters==i, ]-> tmp
    apply(tmp, MARGIN = 2, mean) -> mean_colors[i, ]
  }
  return(mean_colors)
}

moods_info_new <- function(file){
  picture <- readPNG(file)
  dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
  #genie::hclust2(objects = picture) -> genie_clust
  #k <- 7 #liczba kolorow do nastroju
  #cutree(genie_clust, k) -> screenshots_classes
  #mean_color_old(picture, clusters = screenshots_classes) -> mean_colors
  #scene_moods(mean_colors = mean_colors) -> scene_moods
  moods <- readRDS("moods.rda")
  knn(test = picture, train = moods, 1:7, k = 7) -> knn_result
  #as.integer(rollmean(as.integer(knn_result), k = 10)) -> rm_result
  len <- length(knn_result)
  mode_len <- 144
  diff <- len %% mode_len
  for (i in seq.int(1, len - diff, mode_len)) {
    rep(getmode(knn_result[i:(i + mode_len - 1)]), times=mode_len) -> knn_result[i:(i+mode_len-1)]
  }
  rownames(moods)[knn_result] -> moods_info
  return(moods_info)
}

moods_info_new_HSV <- function(file){
  picture <- readPNG(file)
  dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
  picture_hsv <- rgb2hsv(t(picture), maxColorValue = 1)
  picture_hsv <- t(picture_hsv)
  #genie::hclust2(objects = picture) -> genie_clust
  #k <- 7 #liczba kolorow do nastroju
  #cutree(genie_clust, k) -> screenshots_classes
  #mean_color_old(picture, clusters = screenshots_classes) -> mean_colors
  #scene_moods(mean_colors = mean_colors) -> scene_moods
  moods <- readRDS("moods_HSV.rda")
  knn(test = picture[,3], train = moods[, 3], 1:7, k = 7) -> knn_result
  #as.integer(rollmean(as.integer(knn_result), k = 10)) -> rm_result
  #len <- length(knn_result)
  knn_result <- rollapply(knn_result, 72, getmode, fill = NA)
  rownames(moods)[knn_result] -> moods_info
  return(moods_info)
}

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}
file <- "/media/ghost/shared/MiNI.Data_Science/3_semestr/TWD/p1/Results_HSV/HP1(HSV).png"
write(moods_info_new(file), file = "HP1(HSV)_moods_info.csv", sep = ";")
#"love, passion, anger", "innocence, playful, empathy", "friendly, youth,happiness", "madness, insecurity, naive", "nature, danger, immaturity", "isolation, melancholy, passivity", "fantasy, mystical, ilusory"