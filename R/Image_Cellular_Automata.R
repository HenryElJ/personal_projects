
# Clear everything
rm(list = ls()); gc(); graphics.off(); cat("\14")

# Required packages
packages <- c("imager", "Rcpp", "tidyverse", "magick", "animation")
invisible(lapply(packages, library, character.only = T))

# Working directory
setwd("Desktop")

# Game of Life Function
life <- function(mat, mat_name, assign = T){
  
  n <- nrow(mat)
  m <- ncol(mat)
  mat.pad <- rbind(NA, cbind(NA, mat, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- colSums(
    rbind(N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
          NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
          E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
          SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
          S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
          SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
          W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
          NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])), 
    na.rm = T)
  
  # Any live cell with fewer than two live neighbours dies, as if by underpopulation.
  # Any live cell with more than three live neighbours dies, as if by overpopulation.
  mat[which(neigh < 2 | neigh > 3)] <- 0
  
  #Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
  mat[which(neigh == 3)] <- 1
  
  # Any live cell with two or three live neighbours lives on to the next generation.
  mat[which(neigh == 2)] <- mat[which(neigh == 2)]
  
  if(assign == T){
    return(assign(mat_name, mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

# Brian's Brain  Function
brain <- function(mat, mat_name, assign = T){
  
  n <- nrow(mat)
  m <- ncol(mat)
  # Only alive cells are considered neighbours
  mat.pad <- ifelse(rbind(NA, cbind(NA, mat, NA), NA) == 1, 1, 0)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- colSums(
    rbind(N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
          NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
          E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
          SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
          S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
          SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
          W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
          NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])), 
    na.rm = T)
  
  # A dead cell comes alive in the next iteration if it has two alive neighbours
  # A dying cell always dies in the next iteration.
  # An alive cell always goes into dying 
  mat <- ifelse(mat == 0 & neigh == 2, 1, ifelse(mat == 0.5, 0, ifelse(mat == 1, 0.5, mat)))
  
  if(assign == T){
    return(assign(mat_name, mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

# Majority cell wins
majority <- function(mat, mat_name, assign = T){
  
  n <- nrow(mat)
  m <- ncol(mat)
  mat.pad <- rbind(NA, cbind(NA, mat, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- rbind(N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
                 #NN  = as.vector(mat.pad[row_ind - 2, col_ind   ]),
                 NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
                 E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
                 #EE  = as.vector(mat.pad[row_ind   , col_ind + 2]),
                 SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
                 S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
                 #SS  = as.vector(mat.pad[row_ind + 2, col_ind   ]),
                 SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
                 W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
                 #WW  = as.vector(mat.pad[row_ind   , col_ind - 2]),
                 NW = as.vector(mat.pad[row_ind - 1, col_ind - 1]))
  
  # 'Majority' of neighbours determines the cell
  
 mat[colSums(neigh == 0, na.rm = T) > colSums(neigh == 0.5, na.rm = T) & 
        colSums(neigh == 0, na.rm = T) > colSums(neigh == 1, na.rm = T)] <- 0
  
  mat[colSums(neigh == 0.5, na.rm = T) > colSums(neigh == 0, na.rm = T) & 
        colSums(neigh == 0.5, na.rm = T) > colSums(neigh == 1, na.rm = T)] <- 0.5
  
  mat[colSums(neigh == 1, na.rm = T) > colSums(neigh == 0, na.rm = T) & 
        colSums(neigh == 1, na.rm = T) > colSums(neigh == 0.5, na.rm = T)] <- 1
  
  mat[colSums(neigh == 1, na.rm = T) > colSums(neigh == 0, na.rm = T) & 
        colSums(neigh == 1, na.rm = T) > colSums(neigh == 0.5, na.rm = T)] <- 1
  
  if(assign == T){
    return(assign(mat_name, mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

image_ca <- function(filename, type = "grayscale", ca = "brian",
                     threshold = c(1/3, 2/3), iterations = 100, interval_val = 0.1, 
                     plot = F, add_frames = F){
  
  # Clear plots
  graphics.off()
  
  # Load image
  assign("image", grayscale(load.image(filename)), envir = .GlobalEnv)
  
  # Image matrix
  if(type == "bw"){
    assign("image_mat", ifelse(as.matrix(image) <= threshold[1], 0, 1), envir = .GlobalEnv)
  } else {
    assign("image_mat", ifelse(as.matrix(image) <= threshold[1], 0, ifelse(as.matrix(image) <= threshold[2], 0.5, 1)), envir = .GlobalEnv)
  }
  
  if(plot){
    plot(as.cimg(image_mat), axes = F)
    if(askYesNo("Proceed?") == F){break}}
  
  dir.create("temp")
  
  for(i in 1:iterations){
    
    if(i %% 10 == 0 | i == 1){message(i)}
    
    if(i == 1 & add_frames == T){
      for(j in 1:25){
        save.image(as.cimg(image_mat), paste0("temp/_iteration_", str_pad(j, 4, "left", "0"), ".jpeg"), 1)
      }
    } else {
      save.image(as.cimg(image_mat), paste0("temp/iteration_", str_pad(i, 4, "left", "0"), ".jpeg"), 1)
    }
    
    if(ca == "life"){
      life(image_mat, "image_mat")
    } else if(ca == "brain"){
      brain(image_mat, "image_mat")
    } else {
      majority(image_mat, "image_mat")
    }
  }
  
  # List file names and read in
  imgs <- list.files("temp", pattern = "iteration_[0-9]+.jpeg", full.names = T)
  
  img_list <- lapply(imgs, image_read)
  
  # Join the images together
  img_joined <- image_join(img_list)
  
  message("Creating gif @ 25fps")
  message("-- Animating")
  
  ptm <- proc.time()
  # Animate @ 25 fps
  img_animated <- image_animate(img_joined, fps = 25)
  message("-- Time: ", round((proc.time() - ptm)["elapsed"] / 60, 2), " mins")
  
  message("-- Saving")
  ptm <- proc.time()
  # Save
  image_write(image = img_animated, quality = 100, path = paste0("gif_25fps_", format(Sys.time(), "%d%m%Y_%H%M%S"), ".gif"))
  message("-- Time: ", round((proc.time() - ptm)["elapsed"] / 60, 2), " mins")
  
  message("Creating gif @ 50fps")
  message("-- Animating")
  ptm <- proc.time()
  # Animate @ 50 fps
  img_animated <- image_animate(img_joined, fps = 50, optimize = T)
  message("-- Time: ", round((proc.time() - ptm)["elapsed"] / 60, 2), " mins")
  
  message("-- Saving")
  ptm <- proc.time()
  # Save
  image_write(image = img_animated, quality = 100, path = paste0("gif_50fps_", format(Sys.time(), "%d-%m-%Y at %H.%M.%S"), ".gif"))
  message("-- Time: ", round((proc.time() - ptm)["elapsed"] / 60, 2), " mins")
  
  # Delete images
  unlink("temp", recursive = T)
  
}

image_ca("3.jpg", "grayscale", "majority", threshold = c(0.45, 0.65), iterations = 100, add_frames = F, plot = T)
y

# Oscillator for Brian's Brain (for testing) ####
mat <- matrix(c(0,0,0,0,0,0,
                0,0,1,.5,0,0,
                0,.5,0,0,1,0,
                0,1,0,0,.5,0,
                0,0,.5,1,0,0,
                0,0,0,0,0,0),
              nrow = 6, byrow = F)
mat
plot(as.cimg(mat), axes = F)
brain(mat, "mat")
mat
plot(as.cimg(mat), axes = F)


