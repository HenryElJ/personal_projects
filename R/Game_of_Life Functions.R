packages <- c("shiny", "tidyverse", "reshape2",
              "viridis","wesanderson","animation")

invisible(lapply(packages, library, character.only = T))

rm(packages)

life <- function(mat, assign = T){
  
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
  
  mat[which(neigh < 2 | neigh > 3)] <- 0
  mat[which(neigh == 3)] <- 1
  mat[which(neigh == 2)] <- mat[which(neigh == 2)]
  
  if(assign == T){
    return(assign("matrix", mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

col_pal <- c("Default" = "default",
             "Inverted" = "invert", 
             setNames(names(wes_palettes), paste0("Wes Anderson: ", names(wes_palettes))),
             "Viridis: Magma" = "magma",
             "Viridis: Inferno" = "inferno",
             "Viridis: Plasma" = "plasma",
             "Viridis: Viridis" = "viridis",
             "Viridis: Cividis" = "cividis",
             "Viridis: Rocket" = "rocket",
             "Viridis: Mako" = "mako",
             "Viridis: Turbo" = "turbo")

plot_shape <- function(shape,  mirror = "none", transpose = F, col_pal = "default", gridlines = F){
  
  if(mirror == "y"){
    shape <- shape[nrow(shape):1,]
  } else if (mirror == "x"){
    shape <- shape[,ncol(shape):1]
  } else if (mirror == "both"){
    shape <- shape[nrow(shape):1, ncol(shape):1]
  }
  
  if(transpose == T){
    shape <- t(shape)
  }
  
  shape <- rbind(0, cbind(0, shape, 0), 0)
  shape <- melt(shape)
  
  if(col_pal == "default"){
    shape$col_values <- ifelse(shape$value == 0, "white", "black")
  } else if(col_pal == "invert"){
    shape$col_values <- ifelse(shape$value == 0, "black", "white")
  } else if(col_pal%in%names(wes_palettes)){
    shape$col_values <- ifelse(shape$value == 0, "white", sample(wes_palette(col_pal)))
  } else {
    shape$col_values <- ifelse(shape$value == 0, "white", sample(viridis(10, option = col_pal)))
  }
  
  
  plot <- ggplot(shape, aes(Var2, Var1)) + 
    geom_tile(fill = shape$col_values) + 
    scale_y_reverse() +
    theme(legend.position = "none", axis.text = element_blank(), axis.ticks = element_blank()) +
    labs(x = "X Axis", y = "Y Axis")
  
  if(gridlines == F){plot <- plot + theme_void()}
  
  print(plot)
  
}

place_shape <- function(matrix, shape, x, y, mirror = "none", transpose = F){
  
  y <- nrow(matrix) - y
  
  if(mirror == "y"){
    shape <- shape[nrow(shape):1,]
  } else if (mirror == "x"){
    shape <- shape[,ncol(shape):1]
  } else if (mirror == "both"){
    shape <- shape[nrow(shape):1, ncol(shape):1]
  }
  
  if(transpose == T){
    shape <- t(shape)
  }
  
  x_start <- ifelse(ncol(shape)%%2==0, x-ncol(shape)/2+1, x-floor(ncol(shape)/2))
  x_end <- ifelse(ncol(shape)%%2==0, x+ncol(shape)/2, x+floor(ncol(shape)/2))
  
  y_start <- ifelse(nrow(shape)%%2==0, y-nrow(shape)/2+1, y-floor(nrow(shape)/2))
  y_end <- ifelse(nrow(shape)%%2==0, y+nrow(shape)/2, y+floor(nrow(shape)/2))
  
  matrix[y_start:y_end, x_start:x_end] <- shape
  
  return(matrix)
  
}

plot_lexicon <- function(x){
  ggplot(melt(x), aes(Var2, Var1, fill = factor(value))) + 
    geom_tile() + 
    scale_y_reverse() +
    scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
    facet_wrap("L1", scales = "free", ncol = 3) +
    theme(legend.position = "none", 
          strip.text = element_text(size = 15, face = "bold"),
          axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank())
}
