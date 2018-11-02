library(genie)
library(class)
file <- "/media/ghost/shared/MiNI.Data_Science/3_semestr/TWD/p1/demo.png"
#picture <- readPNG(file)
#dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
#genie::hclust2(objects = picture, thresholdGini = 0.05) -> x
#k <- 7
#cutree(x, 7) -> y



moods_info <- function(file){
  picture <- readPNG(file)
  dim(picture) <- c(dim(picture)[1] * dim(picture)[2], dim(picture)[3])
  genie::hclust2(objects = picture, thresholdGini = 0.05) -> genie_clust
  k <- 7 #liczba kolorow do nastroju
  cutree(genie_clust, 7) -> screenshots_classes
  mean_color(picture, clusters = screenshots_classes) -> mean_colors
  scene_moods(mean_colors = mean_colors) -> scene_moods
  as.character(scene_moods) -> scene_moods
  scene_moods[screenshots_classes] -> moods_info
  return(moods_info)
}

scene_moods <- function(mean_colors){
  moods <- readRDS("moods.rda")
  knn(mean_colors, moods, rownames(moods))
}

mean_color <- function(picture, clusters){
  k <- length(unique(clusters))
  mean_colors <- matrix(ncol = 3, nrow = k)
  for(i in 1:k){
    picture[clusters==i, ]-> tmp
    apply(tmp, MARGIN = 2, mean) -> mean_colors[i, ]
  }
  return(mean_colors)
}



write(moods_info(file), file = "moods_info.csv", sep = ";")
#"love, passion, anger", "innocence, playful, empathy", "friendly, youth,happiness", "madness, insecurity, naive", "nature, danger, immaturity", "isolation, melancholy, passivity", "fantasy, mystical, ilusory"