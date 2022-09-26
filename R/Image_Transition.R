

# https://cran.r-project.org/web/packages/imager/vignettes/gettingstarted.html#how-images-are-represented
# https://dahtah.github.io/imager/
# https://stackoverflow.com/questions/9543343/plot-a-jpg-image-using-base-graphics-in-r
# https://stackoverflow.com/questions/14769628/how-to-get-pixel-data-from-an-image-using-r


# Clear everything
rm(list = ls()); gc(); graphics.off(); cat("\14")

# Set working directory
setwd("Desktop")

# Required packages
packages <- c("imager", "Rcpp", "scales", "tidyverse", "magick")
# Install if necessary 
# install.packages(packages)
invisible(lapply(packages, library, character.only = T))

# Name of folder
folder <- "Transition_011"

# Load your input/starting image
input <- grayscale(load.image(paste0(folder, "/transition_a.jpeg")), drop = F)

# Number of pixels
nrow(as.data.frame(input, wide = "c"))

# Number of unique colours
nrow(unique(as.data.frame(input, wide = "c")[, 3:5]))

# Load your output/ending image
output <- grayscale(
  load.image(paste0(folder, "/transition_b.jpeg")), drop = F)

# Number of pixels
nrow(as.data.frame(output, wide = "c"))

# Number of unique colours
nrow(unique(as.data.frame(output, wide = "c")[, 3:5]))

# Make sure your images aren't too large. A good starting point is ~100,000 pixels (400 x 200 images size)
# You want the number of pixels to be equivalent in your input and output image.
# Also make sure both pictures are same orientation (i.e. portrait or landscape).
# Currently only works with black and white images. 
# Note the grayscale(...) function achieves this, but the first and final frame of the gif will be in colour (work on this when I care enough).

# Plot images
plot(input)
plot(output)

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

#head(hex_df); tail(hex_df)

# Visualise all colours
show_col(hex_list, labels = F)

# Remove redundant columns
input_df[, 3:5] <- NULL
output_df[, 3:5] <- NULL

# Let's get this party started
temp <- input_df
i <- 1
ptm <- proc.time()

while (i > 0) {
  
  if (all(temp$hex == output_df$hex)){return(message("Complete"))}
  
  message(i)
  
  ptm_t <- proc.time()
  
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
             paste0(folder, "/transition_", str_pad(i, 4, "left", "0"), ".jpeg"),
             1)
  # Overwrite your temp dataset - to be your new 'starting point'
  assign("temp", unique(temp[, c("x", "y", "hex")]))
  
  i <- i + 1
  
  message("-- Iteration time: ", round((proc.time() - ptm_t)["elapsed"] / 60, 2), " mins")
  message("-- Total time: ", round((proc.time() - ptm)["elapsed"] / 60, 2), " mins")
  message("-- ", sum(temp$hex == output_df$hex), "/", length(output_df$hex), ": ", round(sum(temp$hex == output_df$hex) * 100 / length(output_df$hex), 2), "% complete")
  
}

# Add 50 additional input images to the folder (makes the gif 'flow' better)
for(i in 1:50){save.image(input, paste0(folder, "/_transition_", str_pad(i, 3, "left", "0"), ".jpeg"), 1)}

# List file names and read in
imgs <- c(list.files(folder, pattern = "transition_[0-9]+.jpeg", full.names = T), sort(list.files(folder, pattern = "transition_[0-9]+.jpeg", full.names = T), decreasing = T))

img_list <- lapply(imgs, image_read)

# Join the images together
img_joined <- image_join(img_list)

# Animate @ 25 fps
img_animated <- image_animate(img_joined, fps = 25)

# Save
image_write(image = img_animated, quality = 100, path = paste0(folder, "/transition_25fps.gif"))

# Animate @ 50 fps
img_animated <- image_animate(img_joined, fps = 50)

# Save
image_write(image = img_animated, quality = 100, path = paste0(folder, "/transition_50fps.gif"))

# Remove the additional 50 images
invisible(file.remove(list.files(folder, pattern = "_transition_[0-9]+.jpeg", full.names = T)))

# Do you want to keep the gifs ONLY? If YES:
# invisible(file.remove(list.files(folder, pattern = "*.jpeg", full.names = T)))

