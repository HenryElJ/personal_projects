
# https://cran.r-project.org/web/packages/imager/vignettes/gettingstarted.html#how-images-are-represented
# https://dahtah.github.io/imager/
# https://stackoverflow.com/questions/9543343/plot-a-jpg-image-using-base-graphics-in-r
# https://stackoverflow.com/questions/14769628/how-to-get-pixel-data-from-an-image-using-r

# Clear everything
rm(list = ls()); gc(); graphics.off(); cat("\14")

image_transition <- function(folder_path = "/Users/Henry/Downloads/all faces", use_all = F, random_selection = 5, transition_step = 1, keep_images = F){
  
  # Required packages
  packages <- c("imager", "Rcpp", "tidyverse", "magick")
  
  # Install if necessary 
  new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  if(length(new_packages)){invisible(install.packages(new_packages))}
  
  # Load packages
  invisible(lapply(packages, library, character.only = T))
  
  # Name of new folder
  folder <- paste0(folder_path, "/", round(as.numeric(Sys.time())))
  
  # Create this folder
  dir.create(folder)
  
  # List images
  if(use_all == T){images <- list.files(folder_path, full.names = T)} else {images <- sample(list.files(folder_path, full.names = T), random_selection)}
  
  # Add first image as final image, for gif to loop
  images <- c(images, images[1])
  
  for (i in 1:(length(images)-1)){
    
    message("Transition ", i)
    if(i == 1){ptm_t <- proc.time()}
    ptm_i <- proc.time()
    
    # Load your input/starting image
    if(i == 1){input <- grayscale(load.image(images[i]), drop = F)} else {input <- load.image(tail(list.files(folder, full.names = T), 1))}
    
    # Load your output/ending image
    output <- grayscale(load.image(images[i+1]), drop = F)
    
    # Same number of pixels
    if(nrow(as.data.frame(input, wide = "c")) != nrow(as.data.frame(output, wide = "c"))){message("Images do not have the same dimensions. Moving to next image"); next}
    
    # Image dataframes
    input_df <- as.data.frame(input, wide = "c")
    input_df$hex <- rgb(input_df[, 3], input_df[, 4], input_df[, 5], 1)
    
    output_df <- as.data.frame(output, wide = "c")
    output_df$hex <- rgb(output_df[, 3], output_df[, 4], output_df[, 5], 1)
    
    # Colour value list
    col_list <- distinct(rbind(input_df[3:6], output_df[3:6]), hex, .keep_all = T)
    names(col_list) <- c(1:3, "hex")
    
    # Hex code list
    hex_list <- sort(col_list$hex, decreasing = T)
    
    # Hex code dataframe
    hex_df <- data.frame(hex = hex_list, same = hex_list, darker = lead(hex_list), lighter = lag(hex_list)) %>% 
      fill(darker, .direction = "down") %>% 
      fill(lighter, .direction = "up") %>% 
      pivot_longer(c("same", "darker", "lighter"), "shift", values_to = "new_hex")
    
    # Remove redundant columns
    input_df[, 3:5] <- NULL
    output_df[, 3:5] <- NULL
    
    # Let's get this party started
    temp <- input_df
    if(i == 1){j <- 1}
    k <- 1
    
    while (k > 0) {
      
      message("[", i, "]: ", j)
      
      ptm_j <- proc.time()
      
      # Does the pixel colour need to be shifted up or down
      temp$shift <- ifelse(temp$hex < output_df$hex, "lighter", ifelse(temp$hex > output_df$hex, "darker", "same"))
      
      # Shift pixel colour and append necessary data to plot the image
      temp <- left_join(temp, hex_df, by = c("hex", "shift")) %>%
        select(-hex, -shift) %>% 
        rename(hex = new_hex) %>%
        left_join(col_list, by = "hex") %>%
        pivot_longer(c("1", "2", "3"), "cc") %>%
        mutate(cc = as.numeric(cc))
      
      # Save your new image
      save.image(as.cimg(temp[, c("x", "y", "cc", "value")]),
                 paste0(folder, "/transition_", str_pad(j, 4, "left", "0"), ".jpeg"),
                 1)
      # Overwrite your temp dataset - to be your new 'starting point'
      assign("temp", unique(temp[, c("x", "y", "hex")]))
      
      message("-- Iteration time: ", round((proc.time() - ptm_j)["elapsed"] / 60, 2), " mins")
      message("-- Image time: ", round((proc.time() - ptm_i)["elapsed"] / 60, 2), " mins")
      message("-- Total time: ", round((proc.time() - ptm_t)["elapsed"] / 60, 2), " mins")
      message("-- ", sum(temp$hex == output_df$hex), "/", length(output_df$hex), ": ", round(sum(temp$hex == output_df$hex) * 100 / length(output_df$hex), 2), "% complete")
      
      j <- j + 1
      
      # Breal while loop if image transition is complete #Interesting idea. Break when 1/2, 1/3, 1/4, random -way complete
      if(sum(temp$hex == output_df$hex)/length(output_df$hex) >= transition_step){k <- 0}
      
    }
    
    i <- i + 1
    
  }
  
  message("Complete")
  message("Loading images")
  
  # List file names and read in
  imgs <- list.files(folder, pattern = "transition_[0-9]+.jpeg", full.names = T)
  
  img_list <- lapply(imgs, image_read)
  
  # Join the images together
  img_joined <- image_join(img_list)
  
  message("Creating gif @ 25fps")
  
  # Animate @ 25 fps
  img_animated <- image_animate(img_joined, fps = 25)
  
  # Save
  image_write(image = img_animated, quality = 100, path = paste0(folder, "/transition_25fps.gif"))
  
  message("Creating gif @ 50fps")
  
  # Animate @ 50 fps
  img_animated <- image_animate(img_joined, fps = 50)
  
  # Save
  image_write(image = img_animated, quality = 100, path = paste0(folder, "/transition_50fps.gif"))
  
  # Delete images
  if(keep_images == F){invisible(file.remove(list.files(folder, pattern = "*.jpeg", full.names = T)))}
  
  message("Complete")
}

image_transition(folder_path = "/Users/Henry/Downloads/all faces", use_all = F, random_selection = 50, transition_step = 0.35, keep_images = F)