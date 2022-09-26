# Numberphile

rm(list = ls()); gc(); cat("\14")

setwd("/Users/Henry/Desktop/Project Euler and Numberphile")

packages <- c("tidyverse","viridis","wesanderson","gganimate","animation","gifski","av","transformr","magick","crayon","reshape2")
invisible(lapply(packages, library, character.only = T))

####

#### Random Fibonacci Sequence              ####

options("scipen" = 999, "digits" = 4)

sequence <- c(1, 1)
iterations <- 5500
for (i in 3:iterations){
  if(sample(c(0,1), 1) == 0){
    sequence[i] <- sequence[i-1] - sequence[i-2]
  } else {
    sequence[i] <- sequence[i-1] + sequence[i-2]
  }
}

tail(sequence)

plot(log(abs(sequence)), pch = ".") + 
  lines(x = log(1.132**c(1:iterations)), lty = "dotted")

plot(abs(sequence)**(1/c(1:iterations)), pch = ".") + 
  lines(x = rep(1.132, iterations), lty = "dotted")

#### Trapped Knight                         ####

# 21 22 23 24 25
# 20  7  8  9 10
# 19  6  1  2 11
# 18  5  4  3 12
# 17 16 15 14 13

# 1,1,2,2,3,3,4,4,5,5,...,
# r,d,l,u....

operation <- 1
i <- 1
no_steps <- 1
no_cells <- (60)**2
directions <- c()

while(length(directions) < no_cells){
  if (i%%2==1){
    directions <- c(directions, rep(operation, no_steps))
    no_steps <- no_steps + 0
  }
  if (i%%2==0){
    directions <- c(directions, rep(operation, no_steps))
    no_steps <- no_steps + 1
  }
  operation <- ifelse(operation == 4, 1, operation + 1)
  i <- i+1
}

directions <- c(0, directions[1:no_cells-1])
directions

spiral <- matrix(nrow = sqrt(no_cells), ncol = sqrt(no_cells))
i <- ceiling(sqrt(no_cells)/2)
j <- ceiling(sqrt(no_cells)/2)

for (k in 1:no_cells){
  if (directions[k] == 1){i <- i; j <- j+1}
  if (directions[k] == 2){i <- i+1; j <- j}
  if (directions[k] == 3){i <- i; j <- j-1}
  if (directions[k] == 4){i <- i-1; j <- j}
  spiral[i, j] <- k
}

i <- ceiling(sqrt(no_cells)/2)
j <- ceiling(sqrt(no_cells)/2)

path <- data.frame("row" = i, "col" = j)
sequence <- c()

for (k in 1:max(spiral)){
  
  min <- min(spiral[i-2,j+1],spiral[i-1,j+2],spiral[i+1,j+2],spiral[i+2,j+1],
             spiral[i+2,j-1],spiral[i+1,j-2],spiral[i-1,j-2],spiral[i-2,j-1], 
             na.rm = T)
  coord <- which(spiral == min,
                 arr.ind = T)
  
  path <- rbind(path, coord)
  sequence <- c(sequence, min)
  spiral[i,j] <- NA
  i <- coord[1]
  j <- coord[2]
  
}

path$index <- 1:nrow(path)

trapped_knight <- ggplot(path, aes(row, col)) + 
  geom_point(colour = viridis(nrow(path))) +
  geom_path(colour = viridis(nrow(path))) +
  geom_point(mapping = aes(path[1,1],path[1,2]), 
             shape = 21, colour = "red", fill = "red", size = 1.2) +
  geom_point(mapping = aes(path[nrow(path),1],path[nrow(path),2]), 
             shape = 22, colour = "red", fill = "red", size = 1.2) +
  theme_bw()

trapped_knight

trapped_anim <- trapped_knight + 
  transition_reveal(index) #+
#shadow_wake(wake_length = 0.04, size = 4, colour = 'grey92',
#            alpha = F, wrap = F, falloff = "cubic-in") 

animate(trapped_anim, nframes = ceiling(nrow(path)/4))

# 1 3 6 10
# 2 5 9
# 4 8
# 7

i <- c()
j <- c()
length <- 100
for (index in 1:length){
  i <- c(i, index:1)
  j <- c(j, 1:index)
}

mappings <- cbind(i, j, n = 1:length(i))
mappings
max(mappings[,3])

df <- matrix(nrow = length, ncol = length)
for (index in 1:nrow(mappings)){
  df[mappings[index,1], mappings[index,2]] <- mappings[index,3]
}

i <- 1
j <- 1

path <- data.frame("row" = i, "col" = j)
sequence <- c()

for (k in 1:max(df, na.rm = T)){
  
  min <- min(df[ifelse(i-2<0,0,i-2),j+1],df[i-1,j+2],df[i+1,j+2],df[i+2,j+1],
             df[i+2,j-1],df[i+1,ifelse(j-2<0,0,j-2)],df[i-1,ifelse(j-2<0,0,j-2)],df[ifelse(i-2<0,0,i-2),j-1], 
             na.rm = T)
  
  coord <- which(df == min,
                 arr.ind = T)
  
  path <- rbind(path, coord)
  sequence <- c(sequence, min)
  df[i,j] <- NA
  i <- coord[1]
  j <- coord[2]
  
}

path$index <- 1:nrow(path)

trapped_knight <- ggplot(path, aes(row, col)) + 
  geom_point(colour = viridis(nrow(path))) +
  geom_path(colour = viridis(nrow(path))) +
  geom_point(mapping = aes(path[1,1],path[1,2]), 
             shape = 21, colour = "red", fill = "red", size = 1.2) +
  geom_point(mapping = aes(path[nrow(path),1],path[nrow(path),2]), 
             shape = 22, colour = "red", fill = "red", size = 1.2) +
  scale_y_reverse() +
  theme_bw()

trapped_knight

trapped_anim <- trapped_knight + 
  transition_reveal(index) #+
#shadow_wake(wake_length = 0.04, size = 4, colour = 'grey92',
#            alpha = F, wrap = F, falloff = "cubic-in") 


animate(trapped_anim, ceiling(nrow(path)/4))

#### Game of Pig                            ####

library(tidyverse)
library(crayon)

player <- function(n){
  if(askYesNo("Roll dice?", prompts = getOption("askYesNo", "y/n/c"))){
    roll <<- sample(1:6, 1)
    if(roll == 1){running_total <<- 0; return(message(red("Roll = 1. Turn Over")))}
    running_total <<- running_total + roll
    message(green("Roll = ", roll, ", Running total = ", running_total, ", Score = ", get(paste0("player_score_", n)) + running_total))
    if(get(paste0("player_score_", n)) + running_total >= 100){assign(paste0("player_score_", n), get(paste0("player_score_", n)) + running_total, envir = .GlobalEnv); return("")}
    player(n)
  } else {
    assign(paste0("player_score_", n), get(paste0("player_score_", n)) + running_total, envir = .GlobalEnv)
    running_total <<- 0
  }
}

computer <- function(){
  Sys.sleep(1)
  roll <<- sample(1:6, 1)
  if(roll == 1){running_total <<- 0; return(message(red("Roll = 1. Turn Over")))}
  running_total <<- running_total + roll
  message(green("Roll = ", roll, ", Running total = ", running_total, ", Score = ", computer_score + running_total))
  if(computer_score + running_total >= 100){computer_score <<- computer_score + running_total; return("")}
  if(running_total < 20){computer()}else{computer_score <<- computer_score + running_total; running_total <<- 0}
}

graphics <- function(){
  y <- unlist(mget(c(paste0("player_score_", 1:n_players), ifelse(computer_score >= 0, "computer_score", NA)), envir = .GlobalEnv))
  y <- y[!is.na(y)]
  x <- toupper(gsub("score|_","", names(y)))
  x <- factor(x, levels = x)
  col_pal <- wes_palette("GrandBudapest2", length(x))
  
  print( 
    ggplot() + geom_col(mapping = aes(x, y), fill = col_pal) + 
      geom_abline(intercept = 100, slope = 0, colour = "red", alpha = 0.5) +
      geom_label(aes(x, y/2, label = y)) +
      labs(x = "Players", y = "Score") + coord_flip()+ ylim(0, 106) +
      theme_light()
  )
}

pigGame <- function(n_players = 1, computer = T){
  
  if(!is.null(dev.list())){dev.off()}
  for (n in 1:n_players){assign(paste0("player_score_", n), 0, envir = .GlobalEnv)}
  if(computer == T){computer_score <<- 0}else{computer_score<<-NULL}
  running_total <<- 0
  n_players <<- n_players
  graphics()
  
  while(1<2){
    
    for (n in 1:n_players){
      print(paste("PLAYERS", n, "TURN. CURRENT SCORE:", get(paste0("player_score_", n))))
      player(n)
      graphics()
      if(get(paste0("player_score_", n)) + running_total >= 100){
        graphics()
        return(message(yellow((underline("***** PLAYERS", n, "WINS *****")))))
        break
      }
    }
    if(computer == T){
      print(paste("COMPUTERS TURN. CURRENT SCORE:", computer_score))
      computer()
      graphics()
      if(computer_score + running_total >= 100){
        graphics()
        return(message(yellow((underline("***** COMPUTER WINS *****")))))
        break
      }
    }
  }
}

pigGame(2)


#### Sierpinski Triangle                    ####

coord <- matrix(c(1,2,3,1,3,1), nrow = 3)

x <- 2
y <- 2

for (i in 1:1e4){
  roll <- sample(1:3,1)
  if (roll == 1) {
    x <- x-(x-1)/2
    y <- y-(y-1)/2
  } else if (roll == 2) {
    x <- x-(x-3)/2
    y <- y-(y-1)/2
  } else {
    x <- x-(x-2)/2
    y <- y-(y-3)/2
  }
  coord <- rbind(coord, cbind(x,y))
}

head(coord, 10)

ggplot(data.frame(coord), aes(x = x, y = y)) + 
  geom_point(size = 0.2, colour = rev(heat.colors(nrow(coord)))) +
  scale_y_reverse()


#### Fire Plot                              ####


# The "forest fire": sequence of positive integers where each is chosen to be as small as possible subject to the condition that no three terms 
# a(j), a(j+k), a(j+2k) (for any j and k) form an arithmetic progression.


# 1, 1, 2, 1, 1, 2, 2, 4, 4, 1, 1, 2, 1, 1, 2, 2, 4, 4, 2, 4, 4, 5, 5, 8, 5, 5, 9, 1, 1, 2, ...

sequence <- c(1,1)
sequence_check <- list()

ptm <- proc.time()

for (i in 3:1e5){
  
  if(i%%1e4==0){message(i);  message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  sequence[i] <- 1
  found <- F
  
  while (found == F){
    
    for (j in 1:floor((i-1)/2)){
      
      sequence_check[[j]] <- sequence[i] - sequence[i - j] != sequence[i - j] - sequence[i - 2*j]
      
      if(sequence_check[[j]] == F){
        
        sequence[i] <- sequence[i] + 1
        break
        
      }
      
      if(j == floor((i-1)/2)){
        
        if(all(unlist(sequence_check)) == T){
          
          found <- T
          
        } 
      }
    }
  }
}

sequence_df <- data.frame(n = sequence, index = 1:length(sequence))

sequence_plot <- ggplot(sequence_df, aes(index, n)) + 
  geom_point(size = 0.01, colour =  rocket(1e5, direction = -1)) +
  theme_dark()

sequence_plot

sequence_anim <- sequence_plot + 
  transition_reveal(index) +
  shadow_wake(wake_length = 1.5, size = 5, falloff = "cubic-in")

animate(sequence_anim, duration = 5)


#10000
#8.28 mins
#20000
#40.5 mins
#30000
#206.81 mins
#40000
#373.47 mins
#50000
#520.82 mins
#60000
#893.78 mins
#70000
#1772.35 mins
#80000
#3276.76 mins
#90000
#3752.29 mins
#100000
#3972.77 mins

#### Mountain Plot                          ####

library(RColorBrewer)

convert_2_binary <- function(x){
  binary <- c()
  while(x>0){
    remainder <- x%%2
    binary <- c(remainder, binary)
    x <- floor(x/2)
  }
  paste0(binary)
}

sequence <- as.data.frame(matrix(ncol = 3, nrow = 0))
names(sequence) <- c("i","binary", "sequence")

max_length <- 0
options(scipen = 100,digits = 22)

ptm <- proc.time()

for (i in 1:1e4){
  
  if(i%%1e2==0){message(i);  message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  n <- convert_2_binary(i)
  n_length <- length(n)
  
  if(n_length > max_length){
    
    max_length <- n_length
    sequence[nrow(sequence) + 1,] <- c(i, as.numeric(paste(n, collapse = "")), 0)
    sequence$binary <- str_pad(sequence$binary, max_length, "left", 0)
    next
    
  } else {
    
    for (j in 0:max(sequence$sequence)+1){
      
      if(j == max(sequence$sequence)+1){sequence[nrow(sequence) + 1,] <- c(i, as.numeric(paste(n, collapse = "")), j); break}
      
      n_check <- rowSums(sapply(str_split(sequence[sequence$sequence == j, "binary"], ""), as.numeric))
      
      if(all(as.numeric(n)*n_check == 0)){
        
        sequence[nrow(sequence) + 1,] <- c(i, as.numeric(paste(n, collapse = "")), j)
        break
        
      } else {
        next
      }
    }
  }
}

head(sequence, 100)

col_pal <- rev(colorRampPalette(brewer.pal(9, "Blues"))(max(sequence$sequence)+1))
col_pal1 <- rev(colorRampPalette(brewer.pal(9, "Blues"))(nrow(sequence)))

ggplot(sequence, aes(i, sequence)) + 
  geom_point(size = 0.5, colour = col_pal[sequence$sequence+1])


#### Chapel Plot                            ####

sequence <- c(1)

for (i in 1:1e5){
  sequence[2*i] <- sequence[i]
  sequence[2*i+1] <- sequence[i] + sequence[i+1]
  if(length(sequence) > 1e5){break}
}

length(sequence)

df <- data.frame(n = 1:length(sequence), sequence)
col_pal <- sample(c(paste0("wheat", c("",1:3)), paste0("navajowhite", c("",1:3))), 
                  length(sequence), replace = T)

ggplot(df, aes(x = n, y = sequence)) +
  geom_point(size = 0.001, colour = col_pal)

#### Ulam Warburton Cellular Automation     ####

dev.off()

n <- (100)**2
df <- matrix(rep(0, n), nrow = sqrt(n), byrow = T)
df[sqrt(n)/2,sqrt(n)/2] <- 1
rownames(df) <- rep("", nrow(df))
colnames(df) <- rep("", ncol(df))

for(steps in 1:(sqrt(n)/2)){
  for (i in 1:n){
    
    if(df[i]>0){next}
    
    num1 <- as.numeric(try(df[i+1], T))
    num2 <- ifelse(i-1 < 0, NA, as.numeric(try(df[i-1], T)))
    num3 <- as.numeric(try(df[i+sqrt(n)], T))
    num4 <- ifelse(i-sqrt(n) < 0, NA, as.numeric(try(df[i-sqrt(n)], T)))
    
    df[i] <- ifelse(sum(num1,num2,num3,num4,na.rm = T) == steps, steps+1, df[i])
  }
  #jpeg(paste0("Plots/plot_", steps, ".jpeg"))
  #df[((sqrt(n)/2)-steps):((sqrt(n)/2)+steps),
  #  ((sqrt(n)/2)-steps):((sqrt(n)/2)+steps)]
  heatmap(df, Colv = NA, Rowv = NA, scale = "none", margins = c(0,0), col = wes_palette("FantasticFox1",100,"continuous"))
  #dev.off()
}


#### Fredkin Replicator                     ####

n <- (150)**2
df <- matrix(rep(NA, n), nrow = sqrt(n), byrow = T)
df[sqrt(n)/2,sqrt(n)/2] <- 1
df
df2 <- df

col_pal <- wesanderson::wes_palette("GrandBudapest2", 100, "continuous")

for(steps in 1:(sqrt(n)/2)){
  for (i in 1:n){
    
    num1 <- is.na(try(df[i+1], T))
    num2 <- ifelse(i-1 < 0, NA, is.na(try(df[i-1], T)))
    
    num3 <- is.na(try(df[i+sqrt(n)-1], T))
    num4 <- is.na(try(df[i+sqrt(n)], T))
    num5 <- is.na(try(df[i+sqrt(n)+1], T))
    
    num6 <- ifelse(i-sqrt(n)-1 < 0, NA, is.na(try(df[i-sqrt(n)-1], T)))
    num7 <- ifelse(i-sqrt(n) < 0, NA, is.na(try(df[i-sqrt(n)], T)))
    num8 <- ifelse(i-sqrt(n)+1 < 0, NA, is.na(try(df[i-sqrt(n)+1], T)))
    
    df2[i] <- ifelse(sum(num1,num2,num3,num4,num5,num6,num7,num8)%%2 == 0, NA, sample(1:100,1))
  }
  
  df <- df2
  
  rownames(df2) <- rep("", nrow(df2))
  colnames(df2) <- rep("", ncol(df2))
  
  heatmap(df2, Colv = NA, Rowv = NA, scale = "none", col = col_pal, margins = c(0,0))
  
}

#### Hilbert's Curve                        ####

mappings <- function(curve){
  if(curve == "a"){return(c("a","a","d","b"))}
  if(curve == "b"){return(c("b","c","b","a"))}
  if(curve == "c"){return(c("d","b","c","c"))}
  if(curve == "d"){return(c("c","d","a","d"))}
}

hilberts_sequence <- function(n_generations = 1, start = "a"){
  
  sequence <- c(start)
  
  for (i in 1:n_generations){
    
    dim <- 2^i
    sequence <- unlist(lapply(sequence, mappings))
    
    order <- list()
    for (j in seq(2, dim, 2)){
      order[[paste(j)]] <- rep(c(j-1, j-1, j, j), 2**i/2)
    }
    
    order <- unlist(order)
    sequence <- rbind(sequence, order)
    sequence <- sequence["sequence", order(as.numeric(sequence["order",]))]
    
    
  }
  
  assign("dim", dim, envir = .GlobalEnv)
  assign("sequence", sequence, envir = .GlobalEnv)
  assign("order", order, envir = .GlobalEnv)
  
  return(matrix(sequence, nrow = dim, byrow = T))
  
}

n <- 5
line_size <- 2
to_plot <- hilberts_sequence(n)
to_plot <- melt(to_plot)

plot(c(0, dim+2), c(0, dim), type= "n", xlab = "", ylab = "")

for (i in 1:nrow(to_plot)){
  
  Var1 <- to_plot[i, "Var1"]
  Var2 <- to_plot[i, "Var2"]
  value <- to_plot[i, "value"]
  
  if(value == "a"){
    lines(x = Var2 + c(0,0,0.8,0.8), y = dim + c(0,0.8,0.8,0) - Var1, col = "red", lwd = line_size) # a
  } else if(value == "b"){
    lines(x = Var2 + c(0.8,0,0,0.8), y = dim + c(0.8,0.8,0,0) - Var1, col = "red", lwd = line_size) # b
  } else if(value == "c"){
    lines(x = Var2 + c(0.8,0.8,0,0), y = dim + c(0.8,0,0,0.8) - Var1, col = "red", lwd = line_size) # c
  } else if(value == "d"){
    lines(x = Var2 + c(0,0.8,0.8,0), y = dim + c(0,0,0.8,0.8) - Var1, col = "red", lwd = line_size) # d
  }
}

to_plot <- hilberts_sequence(n-1)
to_plot <- melt(to_plot)

for (i in 1:nrow(to_plot)){
  
  Var1 <- to_plot[i, "Var1"]
  Var2 <- to_plot[i, "Var2"]
  value <- to_plot[i, "value"]
  
  if(value == "a"){
    lines(x = 2*Var2 + c(-1, -1), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(-0.2, 0), y = 2*dim + c(1,1) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(0.8,0.8), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
  } else if(value == "b"){
    lines(x = 2*Var2 + c(-0.2, 0), y = 2*dim + c(1.8,1.8) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(-0.2,-0.2), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(-0.2, 0), y = 2*dim + c(0,0) - 2*Var1, col = "red", lwd = line_size)
  } else if(value == "c"){
    lines(x = 2*Var2 + c(-1,-1), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(-0.2,0), y = 2*dim + c(0.8,0.8) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(0.8,0.8), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
  } else if(value == "d"){
    lines(x = 2*Var2 + c(-0.2,0), y = 2*dim + c(1.8,1.8) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(0,0), y = 2*dim + c(0.8,1) - 2*Var1, col = "red", lwd = line_size)
    lines(x = 2*Var2 + c(-0.2,0), y = 2*dim + c(0,0) - 2*Var1, col = "red", lwd = line_size)
  }
}


#### Sandpiles                              ####

topple <- function(sandpile){
  for(i in 1:length(sandpile)){
    if(sandpile[i] >= 4){
      sandpile[i] <- sandpile[i] - 4
      sandpile[i+1] <- sandpile[i+1] + 1
      sandpile[i-1] <- sandpile[i-1] + 1
      sandpile[i+nrow(sandpile)] <- sandpile[i+nrow(sandpile)] + 1
      sandpile[i-nrow(sandpile)] <- sandpile[i-nrow(sandpile)] + 1
    } else {next}
  }
  if(any(sandpile>=4)){
    topple(sandpile)
  } else {
    assign("sandpile_df", sandpile, envir = .GlobalEnv)
    return(sandpile)
  }
}

sandpile <- function(starting_pile, dim = sqrt(starting_pile)){
  
  sandpile <- matrix(0, nrow = dim, ncol = dim)
  sandpile[ceiling(dim/2), ceiling(dim/2)] <- starting_pile
  
  topple(sandpile)
}

sandpile(3500) # recursive function runs into issues beyond this. C stack error

ptm <- proc.time()

starting_pile <- 1e5
dim <- ceiling(sqrt(starting_pile))
sandpile <- matrix(0, nrow = dim, ncol = dim)
sandpile[ceiling(dim/2), ceiling(dim/2)] <- starting_pile

for(j in 1:(10*starting_pile)){
  for(i in 1:length(sandpile)){
    if(sandpile[i] >= 4){
      sandpile[i] <- sandpile[i] - 4
      sandpile[i+1] <- sandpile[i+1] + 1
      sandpile[i-1] <- sandpile[i-1] + 1
      sandpile[i+nrow(sandpile)] <- sandpile[i+nrow(sandpile)] + 1
      sandpile[i-nrow(sandpile)] <- sandpile[i-nrow(sandpile)] + 1
    }
  }
  if(all(sandpile<4)){assign("sandpile_df", sandpile, envir = .GlobalEnv); return("Done")}
}

proc.time() - ptm

to_plot <- melt(sandpile_df)

for(i in LETTERS[1:8]){
  
  print(i)
  #col_pal <- rev(wes_palette(i))[1:4]
  
  print(
    ggplot(to_plot, aes(Var2, Var1, fill = factor(value))) + 
      geom_tile() +
      scale_fill_manual(values = viridis(4)) +
      labs(fill = "Sandpile")
  )
}

save.image("Sandpile_1e5.RData")
load("Sandpile_1e5.RData")


#### Rule 30 & 90                           ####

rule30_vec <- c("111" = 0, "110" = 0, "101" = 0, "100" = 1, "011" = 1, "010" = 1, "001" = 1, "000" = 0)

rule30 <- function(depth, plot = T){
  
  width <- 2*depth-1
  mat <- matrix(0, nrow = depth, ncol = width)
  mat[1, ceiling(width/2)] <- 1
  mat <- cbind(0, mat, 0)
  
  k <- 1
  nrow_index <- nrow(mat)
  ncol_index <- ceiling(ncol(mat)/2)
  for(i in 2:nrow_index){
    for(j in (ncol_index-k):(ncol_index+k)){
      num1 <- mat[i-1, j-1]
      num2 <- mat[i-1, j]
      num3 <- mat[i-1, j+1]
      
      mat[i, j] <- rule30_vec[paste0(num1, num2, num3)]
    }
    k <- k+1
  }
  
  mat <- mat[,2:(ncol(mat)-1)]
  
  if(plot==T){
    print(
      ggplot(melt(mat), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
        scale_y_reverse() +
        theme_void() + 
        theme(legend.position = "none")
    )
  } else {return(mat)}
}

dev.off()
rule30(250)

rule90_vec <- c("111" = 0, "110" = 1, "101" = 0, "100" = 1, "011" = 1, "010" = 0, "001" = 1, "000" = 0)

rule90 <- function(depth, plot = T){
  
  width <- 2*depth-1
  mat <- matrix(0, nrow = depth, ncol = width)
  mat[1, ceiling(width/2)] <- 1
  mat <- cbind(0, mat, 0)
  
  k <- 1
  nrow_index <- nrow(mat)
  ncol_index <- ceiling(ncol(mat)/2)
  for(i in 2:nrow_index){
    for(j in (ncol_index-k):(ncol_index+k)){
      num1 <- mat[i-1, j-1]
      num2 <- mat[i-1, j]
      num3 <- mat[i-1, j+1]
      
      mat[i, j] <- rule90_vec[paste0(num1, num2, num3)]
    }
    k <- k+1
  }
  
  mat <- mat[,2:(ncol(mat)-1)]
  
  if(plot==T){
    print(
      ggplot(melt(mat), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
        scale_y_reverse() +
        theme_void() + 
        theme(legend.position = "none")
    )
  } else {return(mat)}
}

dev.off()
rule90(500)

#### Two Steps Back Cellular Automation     ####

rule1069_vec <- c(1,0,0,0,0,1,0,1,1,0,1)

rule1069 <- function(depth, plot = T){
  
  width <- 2*depth-1
  mat <- matrix(0, nrow = depth, ncol = width)
  mat[1, ceiling(width/2)] <- 1
  
  for(i in 2:nrow(mat)){
    for(j in 1:ncol(mat)){
      
      active_neigh <-  sum(
        ifelse(i-1 < 1 | j-2 < 1, 0, mat[i-1, j-2]),
        ifelse(i-1 < 1 | j-1 < 1, 0, mat[i-1, j-1]),
        ifelse(i-1 < 1, 0, mat[i-1, j]),
        ifelse(i-1 < 1 | j+1 > ncol(mat), 0, mat[i-1, j+1]),
        ifelse(i-1 < 1 | j+2 > ncol(mat), 0, mat[i-1, j+2]),
        
        ifelse(i-2 < 1 | j-2 < 1, 0, mat[i-2, j-2]),
        ifelse(i-2 < 1 | j-1 < 1, 0, mat[i-2, j-1]),
        ifelse(i-2 < 1, 0, mat[i-2, j]),
        ifelse(i-2 < 1 | j+1 > ncol(mat), 0, mat[i-2, j+1]),
        ifelse(i-2 < 1 | j+2 > ncol(mat), 0, mat[i-2, j+2])
      )
      
      mat[i, j] <- rule1069_vec[active_neigh+1]
    }
  }
  
  #mat <- mat[2:nrow(mat), 3:(ncol(mat)-2)]
  
  if(plot==T){
    print(
      ggplot(melt(mat), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
        scale_y_reverse() +
        theme_void() + 
        theme(legend.position = "none")
    )
  } else {return(mat)}
}

dev.off()
rule1069(250)

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(
        expand_grid(
          expand_grid(
            expand_grid(
              expand_grid(
                expand_grid(
                  expand_grid(x1 = 0:1, 
                              x2 = 0:1), 
                  x3 = 0:1), 
                x4 = 0:1), 
              x5 = 0:1), 
            x6 = 0:1), 
          x7 = 0:1), 
        x8 = 0:1), 
      x9 = 0:1), 
    x10 = 0:1), 
  x11 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules

rules_func <- function(depth, rule = 1070, plot = T){
  
  width <- 4*depth-1
  mat <- matrix(0, nrow = depth, ncol = width)
  mat[1, ceiling(width/2)] <- 1
  
  for(i in 2:nrow(mat)){
    for(j in 1:ncol(mat)){
      
      active_neigh <-  sum(
        ifelse(i-1 < 1 | j-2 < 1, 0, mat[i-1, j-2]),
        ifelse(i-1 < 1 | j-1 < 1, 0, mat[i-1, j-1]),
        ifelse(i-1 < 1, 0, mat[i-1, j]),
        ifelse(i-1 < 1 | j+1 > ncol(mat), 0, mat[i-1, j+1]),
        ifelse(i-1 < 1 | j+2 > ncol(mat), 0, mat[i-1, j+2]),
        
        ifelse(i-2 < 1 | j-2 < 1, 0, mat[i-2, j-2]),
        ifelse(i-2 < 1 | j-1 < 1, 0, mat[i-2, j-1]),
        ifelse(i-2 < 1, 0, mat[i-2, j]),
        ifelse(i-2 < 1 | j+1 > ncol(mat), 0, mat[i-2, j+1]),
        ifelse(i-2 < 1 | j+2 > ncol(mat), 0, mat[i-2, j+2])
      )
      
      mat[i, j] <- as.numeric(rules[rule, active_neigh+1])
    }
  }
  
  if (plot == T){
    return(
      print(
        ggplot(melt(mat), aes(Var2, Var1, fill = factor(value))) + 
          geom_tile() + 
          scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
          scale_y_reverse() +
          theme_void() + 
          theme(legend.position = "none")
      )
    )
  } else {return(mat)}
}

rules_func(100, 623)

dev.off()
ptm <- proc.time()
for(i in nrow(rules):1){
  message(i)
  png(paste0("Cellular Automata Depth 200/Rule ", i, " - ", paste0(rules[i,], collapse = ""),".png"))
  rules_func(200, rule = i)
  dev.off()
  message("Total run time: ", round((proc.time() - ptm)["elapsed"]/60, 2), " mins")
}

dev.off()
rules_func(1000, 623, F)


#### Rock Paper Scissors (Lizard Spock)     ####

rps <- function(mat, assign = T){
  
  n <- nrow(mat)
  m <- ncol(mat)
  mat.pad <- rbind(NA, cbind(NA, mat, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])
  )
  
  mat[mat=="R"] <- ifelse(colSums(neigh[, which(mat=="R")] == "P", na.rm = T) > 2, "P", "R")
  mat[mat=="P"] <- ifelse(colSums(neigh[, which(mat=="P")] == "S", na.rm = T) > 2, "S", "P")
  mat[mat=="S"] <- ifelse(colSums(neigh[, which(mat=="S")] == "R", na.rm = T) > 2, "R", "S")
  
  if(assign == T){
    return(assign("matrix", mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

#set.seed(42)
n_cells <- 1e4
matrix <- matrix(sample(c("R", "P", "S"), n_cells, T), nrow = sqrt(n_cells))

ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
  geom_tile() + 
  scale_fill_manual(breaks = c("R", "P", "S"), values = c("Red", "Orange", "Blue")) + 
  theme_void() +
  theme(legend.position = "none")

dev.off()
ptm <- proc.time()
saveGIF(
  for(i in 1:5000){
    
    print(
      ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("R", "P", "S"), values = c("Red", "Orange", "Blue")) + 
        theme_void() +
        theme(legend.position = "none")
    )
    
    rps(matrix)
    
  }, movie.name = "Rock Paper Scissors.gif", interval = 0.05)
message("Total run time: ", round((proc.time() - ptm)["elapsed"]/60, 2), " mins")

# "Scissors cuts Paper
#  Paper covers Rock
#  Rock crushes Lizard
#  Lizard poisons Spock
#  Spock smashes Scissors
#  Scissors decapitates Lizard
#  Lizard eats Paper
#  Paper disproves Spock
#  Spock vaporizes Rock
#  (and as it always has) Rock crushes Scissors"

rpsls <- function(mat, assign = T){
  
  n <- nrow(mat)
  m <- ncol(mat)
  mat.pad <- rbind(NA, cbind(NA, mat, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])
  )
  
  # Paper and Spock beat Rock. Spock takes precedent as it loses to Paper
  mat[mat=="R"] <- ifelse(colSums(neigh[, which(mat=="R")] == "Sp", na.rm = T) > 2, "Sp", 
                          ifelse(colSums(neigh[, which(mat=="R")] == "P", na.rm = T) > 2, "P", "R"))
  
  # Scissors and Lizard beat Paper. Lizard takes precedent as it loses to Scissors  
  mat[mat=="P"] <- ifelse(colSums(neigh[, which(mat=="P")] == "L", na.rm = T) > 2, "L", 
                          ifelse(colSums(neigh[, which(mat=="P")] == "S", na.rm = T) > 2, "S", "P"))
  
  # Spock and Rock beat Scissors. Rock takes precedent as it loses to Spock  
  mat[mat=="S"] <- ifelse(colSums(neigh[, which(mat=="S")] == "R", na.rm = T) > 2, "R", 
                          ifelse(colSums(neigh[, which(mat=="S")] == "Sp", na.rm = T) > 2, "Sp", "S"))
  
  
  # Rock and Scissors beat Lizard. Scissors takes precedent as it loses to Lizard  
  mat[mat=="L"] <- ifelse(colSums(neigh[, which(mat=="L")] == "S", na.rm = T) > 2, "S", 
                          ifelse(colSums(neigh[, which(mat=="L")] == "R", na.rm = T) > 2, "R", "L"))
  
  
  # Lizard and Paper beat Spock. Paper takes precedent as it loses to Lizard  
  mat[mat=="Sp"] <- ifelse(colSums(neigh[, which(mat=="Sp")] == "P", na.rm = T) > 2, "P",
                           ifelse(colSums(neigh[, which(mat=="Sp")] == "L", na.rm = T) > 2, "L", "Sp"))
  
  if(assign == T){
    return(assign("matrix", mat, envir = .GlobalEnv))
  } else {
    return(mat)
  }
}

#set.seed(42)
n_cells <- 1e4
matrix <- matrix(sample(c("R", "P", "S", "L", "Sp"), n_cells, T), nrow = sqrt(n_cells))

ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
  geom_tile() + 
  scale_fill_manual(breaks = c("R", "P", "S", "L", "Sp"), values = c("Red", "Orange", "Blue", "Green", "Yellow")) + 
  theme_void() +
  theme(legend.position = "none")

dev.off()
ptm <- proc.time()
saveGIF(
  for(i in 1:5000){
    
    print(
      ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("R", "P", "S", "L", "Sp"), values = c("Red", "Orange", "Blue", "Green", "Yellow")) + 
        theme_void() +
        theme(legend.position = "none")
    )
    
    rpsls(matrix)
    
  }, movie.name = "Rock Paper Scissors Lizard Spock.gif", interval = 0.05)
message("Total run time: ", round((proc.time() - ptm)["elapsed"]/60, 2), " mins")

#### Langton's Ants                         ####

langton_turn <- function(turn){
  
  if(turn == "right"){
    if(state == "up"){
      state <- "right"
    } else if (state == "right"){
      state <- "down"
    } else if(state == "down"){
      state <- "left"
    } else if(state == "left"){
      state <- "up"
    }
  } else if (turn == "left"){
    if(state == "up"){
      state <- "left"
    } else if(state == "right"){
      state <- "up"
    }else if(state == "down"){
      state <- "right"
    }else if(state == "left"){
      state <- "down"
    }
  }
  
  assign("state", state, envir = .GlobalEnv)
}

langton_rl <- function(matrix){
  
  assign("col_breaks", paste0(0:1), envir = .GlobalEnv)
  assign("col_values", c("White", "Black"), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("right")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 0
    langton_turn("left")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
langton_rlr <- function(matrix){
  
  assign("col_breaks", paste0(0:2), envir = .GlobalEnv)
  assign("col_values", c("Black", viridis(3)[-3]), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("right")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 2
    langton_turn("left")
  } else if(matrix[i,j]==2){
    matrix[i,j] <- 0
    langton_turn("right")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
langton_llrr <- function(matrix){
  
  assign("col_breaks", paste0(0:3), envir = .GlobalEnv)
  assign("col_values", c("Black", viridis(3)), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("left")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 2
    langton_turn("left")
  } else if(matrix[i,j]==2){
    matrix[i,j] <- 3
    langton_turn("right")
  } else if(matrix[i,j]==3){
    matrix[i,j] <- 0
    langton_turn("right")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
langton_lrrrrrllr <- function(matrix){
  
  assign("col_breaks", paste0(0:8), envir = .GlobalEnv)
  assign("col_values", c("Black", viridis(8)), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("left")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 2
    langton_turn("right")
  } else if(matrix[i,j]==2){
    matrix[i,j] <- 3
    langton_turn("right")
  } else if(matrix[i,j]==3){
    matrix[i,j] <- 4
    langton_turn("right")
  } else if(matrix[i,j]==4){
    matrix[i,j] <- 5
    langton_turn("right")
  }  else if(matrix[i,j]==5){
    matrix[i,j] <- 6
    langton_turn("right")
  }  else if(matrix[i,j]==6){
    matrix[i,j] <- 7
    langton_turn("left")
  }  else if(matrix[i,j]==7){
    matrix[i,j] <- 8
    langton_turn("left")
  }  else if(matrix[i,j]==8){
    matrix[i,j] <- 0
    langton_turn("right")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
langton_llrrrlrlrllr <- function(matrix){
  
  assign("col_breaks", paste0(0:11), envir = .GlobalEnv)
  assign("col_values", c("Black", viridis(11)), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("left")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 2
    langton_turn("left")
  } else if(matrix[i,j]==2){
    matrix[i,j] <- 3
    langton_turn("right")
  } else if(matrix[i,j]==3){
    matrix[i,j] <- 4
    langton_turn("right")
  } else if(matrix[i,j]==4){
    matrix[i,j] <- 5
    langton_turn("right")
  }  else if(matrix[i,j]==5){
    matrix[i,j] <- 6
    langton_turn("left")
  }  else if(matrix[i,j]==6){
    matrix[i,j] <- 7
    langton_turn("right")
  }  else if(matrix[i,j]==7){
    matrix[i,j] <- 8
    langton_turn("left")
  }  else if(matrix[i,j]==8){
    matrix[i,j] <- 9
    langton_turn("right")
  }  else if(matrix[i,j]==9){
    matrix[i,j] <- 10
    langton_turn("left")
  }  else if(matrix[i,j]==10){
    matrix[i,j] <- 11
    langton_turn("left")
  }  else if(matrix[i,j]==11){
    matrix[i,j] <- 0
    langton_turn("right")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
langton_rrlllrlllrrr <- function(matrix){
  
  assign("col_breaks", paste0(0:11), envir = .GlobalEnv)
  assign("col_values", c("Black", viridis(11)), envir = .GlobalEnv)
  
  if(matrix[i,j]==0){
    matrix[i,j] <- 1
    langton_turn("right")
  } else if(matrix[i,j]==1){
    matrix[i,j] <- 2
    langton_turn("right")
  } else if(matrix[i,j]==2){
    matrix[i,j] <- 3
    langton_turn("left")
  } else if(matrix[i,j]==3){
    matrix[i,j] <- 4
    langton_turn("left")
  } else if(matrix[i,j]==4){
    matrix[i,j] <- 5
    langton_turn("left")
  }  else if(matrix[i,j]==5){
    matrix[i,j] <- 6
    langton_turn("right")
  }  else if(matrix[i,j]==6){
    matrix[i,j] <- 7
    langton_turn("left")
  }  else if(matrix[i,j]==7){
    matrix[i,j] <- 8
    langton_turn("left")
  }  else if(matrix[i,j]==8){
    matrix[i,j] <- 9
    langton_turn("left")
  }  else if(matrix[i,j]==9){
    matrix[i,j] <- 10
    langton_turn("right")
  }  else if(matrix[i,j]==10){
    matrix[i,j] <- 11
    langton_turn("right")
  }  else if(matrix[i,j]==11){
    matrix[i,j] <- 0
    langton_turn("right")
  }
  
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(state == "up"){i <- i-1}
  if(state == "right"){j <- j+1}
  if(state == "down"){i <- i+1}
  if(state == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}

## RL

matrix <- matrix(0, nrow = 70, ncol = 70)
i <- 35
j <- 35
state <- "up"

ptm <- proc.time()

for(k in 1:11000){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_rl(matrix)
  
  png(paste0("Langton's Ant/1. RL/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## RLR

matrix <- matrix(0, nrow = 80, ncol = 80)
i <- 40
j <- 30
state <- "up"

ptm <- proc.time()

for(k in 1:13937){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_rlr(matrix)
  
  png(paste0("Langton's Ant/2. RLR/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## LLRR

matrix <- matrix(0, nrow = 60, ncol = 60)
i <- 30
j <- 35
state <- "up"

ptm <- proc.time()

for(k in 1:123157){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_llrr(matrix)
  
  png(paste0("Langton's Ant/3. LLRR/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## LRRRRRLLR

matrix <- matrix(0, nrow = 120, ncol = 120)
i <- 60
j <- 60
state <- "up"

ptm <- proc.time()

for(k in 1:70273){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_lrrrrrllr(matrix)
  
  png(paste0("Langton's Ant/4. LRRRRRLLR/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## LLRRRLRLRLLR

matrix <- matrix(0, nrow = 120, ncol = 120)
i <- 60
j <- 100
state <- "up"

ptm <- proc.time()

for(k in 1:36437){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_llrrrlrlrllr(matrix)
  
  png(paste0("Langton's Ant/5. LLRRRLRLRLLR/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## RRLLLRLLLRRR

matrix <- matrix(0, nrow = 100, ncol = 100)
i <- 30
j <- 80
state <- "up"

ptm <- proc.time()

for(k in 1:32734){
  
  if(k%%100==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  
  langton_rrlllrlllrrr(matrix)
  
  png(paste0("Langton's Ant/6. RRLLLRLLLRRR/Rplot", k, ".png"))
  
  print(
    ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
      geom_tile() +
      scale_fill_manual(breaks = col_breaks, values = col_values) +
      theme_void() +
      theme(legend.position = "none")
  )
  
  dev.off()
}

## 1. RL
## 2. RLR
## 3. LLRR
## 4. LRRRRRLLR
## 5. LLRRRLRLRLLR
## 6. RRLLLRLLLRRR

#png_files <- list.files("Langton's Ant/2. RLR", pattern = ".png$", full.names = TRUE)

#index <- order(as.numeric(gsub("[^0-9]", "", png_files)))
#png_files <- png_files[index]

#gifski(png_files, gif_file = "Langton's Ant/2. RLR.gif", width = 500, height = 500, delay = 0.01)

#### Termite                                ####

termite_direction <- function(turn){
  
  # 1 = NoTurn, 2 = Right, 4 = Down (U-Turn), 8 = Left
  
  if(turn == 2){
    if(direction == "up"){
      direction <- "right"
    } else if (direction == "right"){
      direction <- "down"
    } else if(direction == "down"){
      direction <- "left"
    } else if(direction == "left"){
      direction <- "up"
    }
  } else if (turn == 4){
    if(direction == "up"){
      direction <- "down"
    } else if(direction == "right"){
      direction <- "left"
    }else if(direction == "down"){
      direction <- "up"
    }else if(direction == "left"){
      direction <- "right"
    }
  } else if (turn == 8){
    if(direction == "up"){
      direction <- "left"
    } else if(direction == "right"){
      direction <- "up"
    }else if(direction == "down"){
      direction <- "right"
    }else if(direction == "left"){
      direction <- "down"
    }
  }
  assign("direction", direction, envir = .GlobalEnv)
}
termite_func <- function(matrix){
  
  if(matrix[i,j]==0){
    if(state == 0){
      matrix[i,j] <- stt[1,1]
      termite_direction(stt[1,2])
      state <- stt[1,3]
    } else if (state == 1){
      matrix[i,j] <- stt[2,1]
      termite_direction(stt[2,2])
      state <- stt[2,3]
    }
  } else if(matrix[i,j]==1){
    if(state == 0){
      matrix[i,j] <- stt[1,4]
      termite_direction(stt[1,5])
      state <- stt[1,6]
    } else if (state == 1){
      matrix[i,j] <- stt[2,4]
      termite_direction(stt[2,5])
      state <- stt[2,6]
    }
  }
  
  assign("state", state, envir = .GlobalEnv)
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(direction == "up"){i <- i-1}
  if(direction == "right"){j <- j+1}
  if(direction == "down"){i <- i+1}
  if(direction == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}
termite_snowflake <- function(matrix){
  
  if(matrix[i,j]==0){
    if(state == 0){
      matrix[i,j] <- stt[1,1]
      termite_direction(stt[1,2])
      state <- stt[1,3]
    } else if (state == 1){
      matrix[i,j] <- stt[2,1]
      termite_direction(stt[2,2])
      state <- stt[2,3]
    } else if (state == 2){
      matrix[i,j] <- stt[3,1]
      termite_direction(stt[3,2])
      state <- stt[3,3]
    }
  } else if(matrix[i,j]==1){
    if(state == 0){
      matrix[i,j] <- stt[1,4]
      termite_direction(stt[1,5])
      state <- stt[1,6]
    } else if (state == 1){
      matrix[i,j] <- stt[2,4]
      termite_direction(stt[2,5])
      state <- stt[2,6]
    } else if (state == 2){
      matrix[i,j] <- stt[3,4]
      termite_direction(stt[3,5])
      state <- stt[3,6]
    }
  }
  
  assign("state", state, envir = .GlobalEnv)
  assign("matrix", matrix, envir = .GlobalEnv)
  
  if(direction == "up"){i <- i-1}
  if(direction == "right"){j <- j+1}
  if(direction == "down"){i <- i+1}
  if(direction == "left"){j <- j-1}
  
  assign("i", i, envir = .GlobalEnv)
  assign("j", j, envir = .GlobalEnv)
}

# Standard

matrix <- matrix(0, nrow = 100, ncol = 100)
i <- 50
j <- 80
direction <- "up"
state <- 0

stt <- matrix(c(1, 2, 0, 1, 2, 1, 0, 1, 0, 0, 1, 1), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:8342){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Standard.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Spiral

matrix <- matrix(0, nrow = 100, ncol = 100)
i <- 50
j <- 50
direction <- "up"
state <- 0

stt <- matrix(c(1, 1, 1, 1, 8, 0, 1, 2, 1, 0, 1, 0), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:12536){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Spiral.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Highway

matrix <- matrix(0, nrow = 120, ncol = 120)
i <- 60
j <- 60
direction <- "up"
state <- 0

stt <- matrix(c(1, 2, 1, 0, 2, 1, 1, 1, 0, 1, 1, 1), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:27731){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Highway.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Chaotic

matrix <- matrix(0, nrow = 100, ncol = 100)
i <- 60
j <- 55
direction <- "up"
state <- 0

stt <- matrix(c(1, 2, 1, 1, 8, 1, 1, 2, 1, 0, 2, 0), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:65932){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Chaotic.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Expanding Frame

matrix <- matrix(0, nrow = 80, ncol = 80)
i <- 40
j <- 40
direction <- "up"
state <- 0

stt <- matrix(c(1, 8, 0, 1, 2, 1, 0, 2, 0, 0, 8, 1), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:223577){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Expanding Frame.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Fibonacci

matrix <- matrix(0, nrow = 100, ncol = 100)
i <- 40
j <- 35
direction <- "up"
state <- 0

stt <- matrix(c(1, 8, 1, 1, 8, 1, 1, 2, 1, 0, 1, 0), nrow = 2, byrow = T)

ptm <- proc.time()

for (k in 1:10211){
  if(k%%1000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_func(matrix)
}

dev.off()
png("Termite/Fibonacci.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

# Snowflake

matrix <- matrix(0, nrow = 250, ncol = 250)
i <- 125
j <- 125
direction <- "up"
state <- 0

stt <- matrix(c(1, 8, 1, 1, 2, 0, 1, 4, 1, 1, 4, 2, NA, NA, NA, 0, 4, 0), nrow = 3, byrow = T)

ptm <- proc.time()

for (k in 1:306000){
  if(k%%10000==0){message(k); message(round((proc.time() - ptm)["elapsed"]/60, 2), " mins")}
  termite_snowflake(matrix)
}

dev.off()
png("Termite/Snowflake.png")
print(
  ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) +
    geom_tile() +
    scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
    theme_void() +
    theme(legend.position = "none")
)

#### Forest Fire                            ####

# A burning cell turns into an empty cell
# A tree will burn if at least one neighbor is burning
# A tree ignites with probability f even if no neighbor is burning
# An empty space fills with a tree with probability p

forestfire <- function(matrix, f, p){
  
  mat.pad <- rbind(NA, cbind(NA, matrix, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])
  )
  
  matrix[matrix==2] <- 0
  matrix[matrix==1] <- ifelse(colSums(neigh[, which(matrix==1)] == 2, na.rm = T) > 0, 2, 1)
  matrix[matrix==1] <- sample(c(1, 2), sum(matrix==1), T, c(1-f, f))
  matrix[matrix==0] <- sample(c(0, 1), sum(matrix==0), T, c(1-p, p))
  
  assign("matrix", matrix, envir = .GlobalEnv)
}

n <- 200
m <- 200
matrix <- matrix(sample(c(0, 1), n*m, T, c(0.1, 0.9)), nrow = n, ncol = m)

#test_prob <- 5e-3
#sum(sample(c(0,1), n*m, T, c(1-test_prob, test_prob)))

save_gif(
  for(k in 1:1000){
    
    forestfire(matrix, 5e-6, 1e-2)
    
    print(
      ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
        geom_tile() + 
        scale_fill_manual(breaks = c("0", "1", "2"), values = c("White", "Green", "Red")) +
        scale_y_reverse() +
        theme_void() + 
        theme(legend.position = "none")
    )
  }, "Forest Fire/Forest Fire.gif", delay = 0.1)

#### Samasta Mandala                        ####

# Moore neighbourhood r = 1

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(
        expand_grid(
          expand_grid(
            expand_grid(
              expand_grid(x1 = 0:1, 
                          x2 = 0:1), 
              x3 = 0:1), 
            x4 = 0:1), 
          x5 = 0:1), 
        x6 = 0:1), 
      x7 = 0:1), 
    x8 = 0:1),
  x9 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules_func <- function(matrix, rule){
  
  mat.pad <- rbind(NA, cbind(NA, matrix, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- colSums(rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])
  ), na.rm = T)
  
  assign("matrix", matrix(as.numeric(rules[rule, neigh+1]), nrow = n, ncol = m), envir = .GlobalEnv)
  assign("col_pal", c("White", wes_palette("Royal1", 8, "continuous"))[neigh+1], envir = .GlobalEnv)
  
}

#matrices <- list()

for(rule in 1:nrow(rules)){
  message(rule)
  
  #  if(rule > 1){
  #    
  #    matrices[[rule-1]] <- matrix
  #    
  #    png(paste0("Samasta Mandala/PNG/Rule ", rule-1,  " - ", paste0(rules[rule-1,], collapse = ""), ".png"))
  #    print(
  #      ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
  #        geom_tile(fill = col_pal) + 
  #        #scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
  #        scale_y_reverse() +
  #        theme_void() + 
  #        theme(legend.position = "none")
  #    )
  #    dev.off()
  #  }
  
  n <- 201
  m <- n
  iterations <- ceiling(n/2)
  matrix <- matrix(0, nrow = n, ncol = m)
  matrix[iterations, iterations] <- 1
  
  save_gif(
    for(k in 1:iterations){
      
      if(k == 1){col_pal <- c(ifelse(matrix == 1, "#7BAFD4", "White"))}
      
      print(
        ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
          geom_tile(fill = col_pal) +
          #geeom_tile() +
          #scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
          theme_void() + 
          theme(legend.position = "none") +
          coord_equal()
      )
      
      if(k < iterations){rules_func(matrix, rule)}
      
    }, paste0("Samasta Mandala/GIF/_Rule ", rule, " - ",  paste0(rules[rule,], collapse = ""), ".gif"), delay = 0.1, 
    height = 500, width = 500, res = 144)
}

#saveRDS(matrices, "Samasta Mandala/Final Matrices.RDS")
matrices <- readRDS( "Samasta Mandala/Final Matrices.RDS")

# Von Neumann neighbourhood r = 1

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(x1 = 0:1, 
                  x2 = 0:1), 
      x3 = 0:1), 
    x4 = 0:1), 
  x5 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules_func <- function(matrix, rule){
  
  mat.pad <- rbind(NA, cbind(NA, matrix, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- colSums(rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1])
  ), na.rm = T)
  
  assign("matrix", matrix(as.numeric(rules[rule, neigh+1]), nrow = n, ncol = m), envir = .GlobalEnv)
  #assign("col_pal", c("White", wes_palette("Royal1", 8, "continuous"))[neigh+1], envir = .GlobalEnv)
  
}

for(rule in 1:nrow(rules)){
  
  message(rule)
  
  if(rule > 1){
    
    to_plot <- ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
      geom_tile() + 
      scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
      scale_y_reverse() +
      theme_void() + 
      theme(legend.position = "none")
    
    ggsave(paste0("Samasta Mandala/Von Neumann Neighbourhood/r = 1/PNG/Rule ", rule-1, " - ",  paste0(rules[rule-1,], collapse = ""), ".png"), 
           to_plot, "png", height = 5, width = 5, units = "cm")#, dpi = 2000)
    
  }
  
  n <- 101
  m <- n
  iterations <- ceiling(n/2)
  matrix <- matrix(0, nrow = n, ncol = m)
  matrix[iterations, iterations] <- 1
  
  save_gif(
    for(k in 1:iterations){
      
      if(k == 1){col_pal <- c(ifelse(matrix == 1, "#7BAFD4", "White"))}
      
      print(
        ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
          #geom_tile(fill = col_pal) +
          geom_tile() +
          scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
          theme_void() + 
          theme(legend.position = "none") +
          coord_equal()
      )
      
      if(k < iterations){rules_func(matrix, rule)}
      
    }, paste0("Samasta Mandala/Von Neumann Neighbourhood/r = 1/GIF/Rule ", rule, " - ",  paste0(rules[rule,], collapse = ""), ".gif"), delay = 0.1, 
    height = 500, width = 500, res = 144)
}

# Von Neumann neighbourhood r = 2

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(
        expand_grid(
          expand_grid(
            expand_grid(
              expand_grid(
                expand_grid(
                  expand_grid(
                    expand_grid(
                      expand_grid(x1 = 0:1, 
                                  x2 = 0:1), 
                      x3 = 0:1), 
                    x4 = 0:1), 
                  x5 = 0:1), 
                x6 = 0:1), 
              x7 = 0:1), 
            x8 = 0:1),
          x9 = 0:1),
        x10 = 0:1),
      x11 = 0:1),
    x12 = 0:1),
  x13 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules_func <- function(matrix, rule){
  
  mat.pad <- rbind(NA, rbind(NA, cbind(NA, cbind(NA, matrix, NA), NA), NA), NA)
  row_ind <- 3:(n + 2)
  col_ind <- 3:(m + 2)
  
  neigh <- colSums(rbind(
    N  = as.vector(mat.pad[row_ind - 1, col_ind    ]),
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    E  = as.vector(mat.pad[row_ind    , col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    S  = as.vector(mat.pad[row_ind + 1, col_ind    ]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    W  = as.vector(mat.pad[row_ind    , col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1]),
    
    NN  = as.vector(mat.pad[row_ind - 2, col_ind    ]),
    EE  = as.vector(mat.pad[row_ind    , col_ind + 2]),
    SS  = as.vector(mat.pad[row_ind + 2, col_ind    ]),
    WW  = as.vector(mat.pad[row_ind    , col_ind - 2])
  ), na.rm = T)
  
  assign("matrix", matrix(as.numeric(rules[rule, neigh+1]), nrow = n, ncol = m), envir = .GlobalEnv)
  #assign("col_pal", c("White", wes_palette("Royal1", 12, "continuous"))[neigh+1], envir = .GlobalEnv)
  
}

for (rule in 1:nrow(rules)){
  
  message(rule)
  
  n <- 101
  m <- n
  matrix <- matrix(0, nrow = n, ncol = m)
  centre <- ceiling(n/2)
  iterations <- ceiling(n/4)
  matrix[centre, centre] <- 1
  
  for(k in 1:iterations){
    
    if(k==iterations){
      
      to_plot <- ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
        #geom_tile(fill = col_pal) +
        geom_tile() +
        scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) + 
        theme_void() + 
        theme(legend.position = "none") +
        coord_equal()
      
      ggsave(paste0("Samasta Mandala/Von Neumann Neighbourhood/r = 2/Rule ", rule, " - ",  paste0(rules[rule,], collapse = ""), ".png"), 
             to_plot, "png", height = 5, width = 5, units = "cm")#, dpi = 2000)
      
    }
    
    rules_func(matrix, rule)
    
  }
}

# Diagonal neighbourhood r = 1

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(x1 = 0:1, 
                  x2 = 0:1), 
      x3 = 0:1), 
    x4 = 0:1), 
  x5 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules_func <- function(matrix, rule){
  
  mat.pad <- rbind(NA, cbind(NA, matrix, NA), NA)
  row_ind <- 2:(n + 1)
  col_ind <- 2:(m + 1)
  
  neigh <- colSums(rbind(
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1])
  ), na.rm = T)
  
  assign("matrix", matrix(as.numeric(rules[rule, neigh+1]), nrow = n, ncol = m), envir = .GlobalEnv)
  #assign("col_pal", c("White", wes_palette("Royal1", 8, "continuous"))[neigh+1], envir = .GlobalEnv)
  
}

for(rule in 1:nrow(rules)){
  
  message(rule)
  
  if(rule > 1){
    
    to_plot <- ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
      geom_tile() + 
      scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
      scale_y_reverse() +
      theme_void() + 
      theme(legend.position = "none")
    
    ggsave(paste0("Samasta Mandala/Diagonal Neighbourhood/r = 1/PNG/Rule ", rule-1, " - ",  paste0(rules[rule-1,], collapse = ""), ".png"), 
           to_plot, "png", height = 5, width = 5, units = "cm")#, dpi = 2000)
    
  }
  
  n <- 101
  m <- n
  iterations <- ceiling(n/2)
  matrix <- matrix(0, nrow = n, ncol = m)
  matrix[iterations, iterations] <- 1
  
  save_gif(
    for(k in 1:iterations){
      
      if(k == 1){col_pal <- c(ifelse(matrix == 1, "#7BAFD4", "White"))}
      
      print(
        ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
          #geom_tile(fill = col_pal) +
          geom_tile() +
          scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
          theme_void() + 
          theme(legend.position = "none") +
          coord_equal()
      )
      
      if(k < iterations){rules_func(matrix, rule)}
      
    }, paste0("Samasta Mandala/Diagonal Neighbourhood/r = 1/GIF/Rule ", rule, " - ",  paste0(rules[rule,], collapse = ""), ".gif"), delay = 0.1, 
    height = 500, width = 500, res = 144)
}

# Diagonal neighbourhood r = 2

rules <- expand_grid(
  expand_grid(
    expand_grid(
      expand_grid(
        expand_grid(
          expand_grid(
            expand_grid(
              expand_grid(x1 = 0:1, 
                          x2 = 0:1), 
              x3 = 0:1), 
            x4 = 0:1), 
          x5 = 0:1),
        x6 = 0:1), 
      x7 = 0:1), 
    x8 = 0:1),
  x9 = 0:1)

rules <- rules[rules$x1!=0 | rules$x2!=0,]

rules_func <- function(matrix, rule){
  
  mat.pad <- rbind(NA, rbind(NA, cbind(NA, cbind(NA, matrix, NA), NA), NA), NA)
  row_ind <- 3:(n + 2)
  col_ind <- 3:(m + 2)
  
  neigh <- colSums(rbind(
    NE = as.vector(mat.pad[row_ind - 1, col_ind + 1]),
    SE = as.vector(mat.pad[row_ind + 1, col_ind + 1]),
    SW = as.vector(mat.pad[row_ind + 1, col_ind - 1]),
    NW = as.vector(mat.pad[row_ind - 1, col_ind - 1]),
    
    NEE = as.vector(mat.pad[row_ind - 2, col_ind + 2]),
    SEE = as.vector(mat.pad[row_ind + 2, col_ind + 2]),
    SWW = as.vector(mat.pad[row_ind + 2, col_ind - 2]),
    NWW = as.vector(mat.pad[row_ind - 2, col_ind - 2])
  ), na.rm = T)
  
  assign("matrix", matrix(as.numeric(rules[rule, neigh+1]), nrow = n, ncol = m), envir = .GlobalEnv)
  #assign("col_pal", c("White", wes_palette("Royal1", 8, "continuous"))[neigh+1], envir = .GlobalEnv)
  
}

for(rule in 1:nrow(rules)){
  
  message(rule)
  
  if(rule > 1){
    
    to_plot <- ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
      geom_tile() + 
      scale_fill_manual(breaks = c("0", "1"), values = c("white", "black")) +
      scale_y_reverse() +
      theme_void() + 
      theme(legend.position = "none")
    
    ggsave(paste0("Samasta Mandala/Diagonal Neighbourhood/r = 2/PNG/Rule ", rule-1, " - ",  paste0(rules[rule-1,], collapse = ""), ".png"), 
           to_plot, "png", height = 5, width = 5, units = "cm")#, dpi = 2000)
    
  }
  
  n <- 101
  m <- n
  centre <- ceiling(n/2)
  iterations <- ceiling(n/4)
  matrix <- matrix(0, nrow = n, ncol = m)
  matrix[centre, centre] <- 1
  
  save_gif(
    for(k in 1:iterations){
      
      if(k == 1){col_pal <- c(ifelse(matrix == 1, "#7BAFD4", "White"))}
      
      print(
        ggplot(melt(matrix), aes(Var2, Var1, fill = factor(value))) + 
          #geom_tile(fill = col_pal) +
          geom_tile() +
          scale_fill_manual(breaks = c("0", "1"), values = c("White", "Black")) +
          theme_void() + 
          theme(legend.position = "none") +
          coord_equal()
      )
      
      if(k < iterations){rules_func(matrix, rule)}
      
    }, paste0("Samasta Mandala/Diagonal Neighbourhood/r = 2/GIF/Rule ", rule, " - ",  paste0(rules[rule,], collapse = ""), ".gif"), delay = 0.1, 
    height = 500, width = 500, res = 144)
}
