# Game of Life 

rm(list = ls()); gc(); cat("\14")

setwd("/Users/Henry/Desktop/Project Euler and Numberphile/Game of Life")

packages <- c("tidyverse","viridis","wesanderson","gganimate","gifski","av","transformr", "magick","crayon", "reshape2")
invisible(lapply(packages, library, character.only = T))

for(i in 1:1e2){
  
  png(paste0("Images/",str_pad(i, 4,"left", 0), ".png"))
  
  print(
    plot_shape(matrix)
  )
  
  dev.off()
  
  life(matrix)
  
}

image_list <- list.files("Images/", pattern = "\\.png$")
images <- lapply(paste0("Images/", image_list), image_read)
images <- image_join(images)

animation <- image_animate(images, fps = 50, loop = 5) #, optimise = T, dispose = "previous")
image_write(animation, paste0("Gifs/Boss Battle Sped Up.gif"))

invisible(file.remove(paste0("Images/", image_list)))