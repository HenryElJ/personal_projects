rm(list=ls()); gc(); dev.off()
library(tidyverse); library(readxl); library(readODS)
setwd("/Users/Henry/Desktop/Indices of Deprivation")

postcode <- read_csv("postcodes.csv")
exp_dist <- function(x){-23*log(1-(x)*(1-exp(-100/23)))}

### England                                         ----

all_iod2019 <- read_csv("england_ranks.csv") %>% 
  left_join(read_excel("england_indicators.xlsx",sheet=2))

indicators <- read_excel("england_indicators.xlsx",sheet=2) %>%
  left_join(read_excel("england_indicators.xlsx",sheet=3)) %>%
  left_join(read_excel("england_indicators.xlsx",sheet=4)) %>%
  left_join(read_excel("england_indicators.xlsx",sheet=5)) %>%
  left_join(read_excel("england_indicators.xlsx",sheet=6)) %>%
  left_join(read_excel("england_indicators.xlsx",sheet=7))

glimpse(all_iod2019)
glimpse(indicators)

# Income Deprivation Domain                         ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Income Domain numerator","Income Score (rate)","Income Score - exponentially transformed",
               "Income Rank (where 1 is most deprived)","Income Decile (where 1 is most deprived 10% of LSOAs)",
               "Total population: mid 2015 (excluding prisoners)")

income_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  rename(rj = "Income Domain numerator", nj = "Total population: mid 2015 (excluding prisoners)") %>% 
  group_by(`Local Authority District code (2019)`) %>%
  mutate(rj = ifelse(is.na(rj),0,rj), 
         mj = log((rj+0.5)/(nj-rj+0.5)), 
         sj.2 = ((nj+1)*(nj+2))/(nj*(rj+1)*(nj-rj+1)),
         M=log((sum(rj)+0.5)/(sum(nj)-sum(rj)+0.5)), 
         k = n(), 
         `(mj-M).2` = (mj-M)^2,
         tj.2 = (1/(k-1))*sum(`(mj-M).2`),
         wj = (1/sj.2)/(1/sj.2+1/tj.2),
         `m*j` = wj*mj+(1-wj)*M,
         zj = exp(`m*j`)/(1+exp(`m*j`)),
         zj = ifelse(is.na(zj),rj/nj,zj)) %>%
  ungroup() %>%
  select(-mj,-sj.2,-M,-k,-`(mj-M).2`,-tj.2,-wj,-`m*j`) %>%
  rename("Income Domain numerator" = rj, "Total population: mid 2015 (excluding prisoners)" = nj, income_score = zj)

income_re %>% filter(income_score!=Inf) %>% select(`Income Score (rate)`,income_score) %>% cor()
income_re %>% filter(income_score!=Inf) %>% ggplot(aes(x=`Income Score (rate)`,y=income_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

# Employment Deprivation Domain                     ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Employment Domain numerator","Employment Score (rate)","Employment Score - exponentially transformed",
               "Employment Rank (where 1 is most deprived)","Employment Decile (where 1 is most deprived 10% of LSOAs)",
               "Working age population 18-59/64: for use with Employment Deprivation Domain (excluding prisoners)")

employment_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  rename(rj = "Employment Domain numerator", nj = "Working age population 18-59/64: for use with Employment Deprivation Domain (excluding prisoners)") %>% 
  group_by(`Local Authority District code (2019)`) %>%
  mutate(rj = ifelse(is.na(rj),0,rj), 
         mj = log((rj+0.5)/(nj-rj+0.5)), 
         sj.2 = ((nj+1)*(nj+2))/(nj*(rj+1)*(nj-rj+1)),
         M=log((sum(rj)+0.5)/(sum(nj)-sum(rj)+0.5)), 
         k = n(), 
         `(mj-M).2` = (mj-M)^2,
         tj.2 = (1/(k-1))*sum(`(mj-M).2`),
         wj = (1/sj.2)/(1/sj.2+1/tj.2),
         `m*j` = wj*mj+(1-wj)*M,
         zj = exp(`m*j`)/(1+exp(`m*j`)),
         zj = ifelse(is.na(zj),rj/nj,zj)) %>%
  ungroup() %>%
  select(-mj,-sj.2,-M,-k,-`(mj-M).2`,-tj.2,-wj,-`m*j`) %>%
  rename("Employment Domain numerator" = rj, "Working age population 18-59/64: for use with Employment Deprivation Domain (excluding prisoners)" = nj, employment_score = zj)

employment_re %>% filter(employment_score!=Inf) %>% select(`Employment Score (rate)`,employment_score) %>% cor()
employment_re %>% filter(employment_score!=Inf) %>% ggplot(aes(x=`Employment Score (rate)`,y=employment_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

# Health Deprivation and Disability Domain          ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Years of potential life lost indicator",
               "Comparative illness and disability ratio indicator",
               "Acute morbidity indicator",
               "Mood and anxiety disorders indicator",
               "Health Deprivation and Disability Score","Health Score - exponentially transformed",
               "Health Deprivation and Disability Rank (where 1 is most deprived)","Health Deprivation and Disability Decile (where 1 is most deprived 10% of LSOAs)")

health_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  mutate(years_lost_rank = rank(`Years of potential life lost indicator`)/n(),
         illness_disability_rank = rank(`Comparative illness and disability ratio indicator`)/n(),
         morbidity_rank = rank(`Acute morbidity indicator`)/n(),
         anxiety_rank = rank(`Mood and anxiety disorders indicator`)/n(),
         
         years_lost = 0.271*qnorm(years_lost_rank),#,mean = mean(years_lost_rank),sd=sd(years_lost_rank)),
         illness_disability = 0.300*qnorm(illness_disability_rank),#,mean = mean(illness_disability_rank),sd=sd(illness_disability_rank)),
         morbidity = 0.256*qnorm(morbidity_rank),#,mean = mean(morbidity_rank),sd=sd(morbidity_rank)),
         anxiety = 0.172*qnorm(anxiety_rank),#,mean = mean(anxiety_rank),sd=sd(anxiety_rank)),
         
         health_score = (years_lost+illness_disability+morbidity+anxiety)
  )

health_re %>% filter(health_score!=Inf) %>% select(`Health Deprivation and Disability Score`,health_score) %>% cor()
health_re %>% filter(health_score!=Inf) %>% ggplot(aes(x=`Health Deprivation and Disability Score`,y=health_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

# Education, Skills & Training Deprivation Domain   ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Staying on in education post 16 indicator",
               "Entry to higher education indicator",
               "Adult skills and English language proficiency indicator",
               "Education, Skills and Training Score","Employment Score - exponentially transformed",
               "Education, Skills and Training Rank (where 1 is most deprived)",
               "Education, Skills and Training Decile (where 1 is most deprived 10% of LSOAs)",
               "Children and Young People Sub-domain Score",                                                        
               "Children and Young People Sub-domain Rank (where 1 is most deprived)",                              
               "Children and Young People Sub-domain Decile (where 1 is most deprived 10% of LSOAs)",               
               "Adult Skills Sub-domain Score",                                                                     
               "Adult Skills Sub-domain Rank (where 1 is most deprived)",                                           
               "Adult Skills Sub-domain Decile (where 1 is most deprived 10% of LSOAs)")

education_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  mutate(staying_in_edu_rank = rank(`Staying on in education post 16 indicator`)/n(),
         higher_edu_entry_rank = rank(`Entry to higher education indicator`)/n(),
         
         staying_in_edu = 0.126*qnorm(staying_in_edu_rank,mean = mean(staying_in_edu_rank),sd=sd(staying_in_edu_rank)),
         higher_edu_entry = 0.208*qnorm(higher_edu_entry_rank,mean = mean(higher_edu_entry_rank),sd=sd(higher_edu_entry_rank)),
         
         children = staying_in_edu+higher_edu_entry,
         
         children_subdomain = -23*log(1-(rank(children)/n())*(1-exp(-100/23))),
         adult_subdomain = -23*log(1-(rank(`Adult skills and English language proficiency indicator`)/n())*(1-exp(-100/23))),
         
         education_score = 0.5*(children_subdomain+adult_subdomain)
  )

education_re %>% filter(education_score!=Inf) %>% select(`Education, Skills and Training Score`,education_score) %>% cor()
education_re %>% filter(education_score!=Inf) %>% ggplot(aes(x=`Education, Skills and Training Score`,y=education_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

#education_re %>% filter(children!=Inf) %>% select(`Children and Young People Sub-domain Score`,children) %>% cor()
#education_re %>% filter(children!=Inf) %>% ggplot(aes(x=`Children and Young People Sub-domain Score`,y=children))+geom_point()

#education_re %>% filter(`Adult skills and English language proficiency indicator`!=Inf) %>% select(`Adult Skills Sub-domain Score`,`Adult skills and English language proficiency indicator`) %>% cor()
#education_re %>% filter(`Adult skills and English language proficiency indicator`!=Inf) %>% ggplot(aes(x=`Adult Skills Sub-domain Score`,y=`Adult skills and English language proficiency indicator`))+geom_point()

# Barriers to Housing & Services Domain             ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Road distance to a post office indicator (km)",
               "Road distance to a primary school indicator (km)",
               "Road distance to general store or supermarket indicator (km)",
               "Road distance to a GP surgery indicator (km)",
               "Household overcrowding indicator",
               "Homelessness indicator (rate per 1000 households)",
               "Owner-occupation affordability (component of housing affordability indicator)",
               "Private rental affordability (component of housing affordability indicator)",
               "Housing affordability indicator",
               "Barriers to Housing and Services Score","Barriers Score - exponentially transformed",
               "Barriers to Housing and Services Rank (where 1 is most deprived)",                                 
               "Barriers to Housing and Services Decile (where 1 is most deprived 10% of LSOAs)",
               "Geographical Barriers Sub-domain Score",                                                            
               "Geographical Barriers Sub-domain Rank (where 1 is most deprived)",                                  
               "Geographical Barriers Sub-domain Decile (where 1 is most deprived 10% of LSOAs)",                   
               "Wider Barriers Sub-domain Score",                                                                   
               "Wider Barriers Sub-domain Rank (where 1 is most deprived)",                                         
               "Wider Barriers Sub-domain Decile (where 1 is most deprived 10% of LSOAs)")

barriers_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  mutate(post_office_rank = rank(`Road distance to a post office indicator (km)`)/n(),
         primary_school_rank = rank(`Road distance to a primary school indicator (km)`)/n(),
         supermarket_rank = rank(`Road distance to general store or supermarket indicator (km)`)/n(),
         gp_rank = rank(`Road distance to a GP surgery indicator (km)`)/n(),
         overcrowding_rank = rank(`Household overcrowding indicator`)/n(),
         homelessness_rank = rank(`Homelessness indicator (rate per 1000 households)`)/n(),
         owner_occ_rank = rank(`Owner-occupation affordability (component of housing affordability indicator)`)/n(),
         private_rental_rank = rank(`Private rental affordability (component of housing affordability indicator)`)/n(),
         housing_affordability_rank = rank(`Housing affordability indicator`)/n(),
         
         post_office = qnorm(post_office_rank,mean = mean(post_office_rank),sd=sd(post_office_rank)),
         primary_school = qnorm(primary_school_rank,mean = mean(primary_school_rank),sd=sd(primary_school_rank)),
         supermarket = qnorm(supermarket_rank,mean = mean(supermarket_rank),sd=sd(supermarket_rank)),
         gp = qnorm(gp_rank,mean = mean(gp_rank),sd=sd(gp_rank)),
         
         geo = post_office+primary_school+supermarket+gp,
         
         overcrowding = qnorm(overcrowding_rank),#mean = mean(overcrowding_rank),sd=sd(overcrowding_rank)),
         homelessness = qnorm(homelessness_rank),#mean = mean(homelessness_rank),sd=sd(homelessness_rank)),
         owner_occ = qnorm(owner_occ_rank,mean = mean(owner_occ_rank),sd=sd(owner_occ_rank)),
         private_rental = qnorm(private_rental_rank,mean = mean(private_rental_rank),sd=sd(private_rental_rank)),
         housing_affordability = qnorm(housing_affordability_rank,mean = mean(housing_affordability_rank),sd=sd(housing_affordability_rank)),
         
         wider = overcrowding+homelessness+owner_occ+private_rental+housing_affordability,
         
         geo_subdomain = -23*log(1-(rank(geo)/n())*(1-exp(-100/23))),
         wider_subdomain = -23*log(1-(rank(wider)/n())*(1-exp(-100/23))),
         
         barriers_score = 0.5*(geo_subdomain+wider_subdomain)
  )

barriers_re %>% filter(barriers_score!=Inf) %>% select(`Barriers to Housing and Services Score`,barriers_score) %>% cor()
barriers_re %>% filter(barriers_score!=Inf) %>% ggplot(aes(x=`Barriers to Housing and Services Score`,y=barriers_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

#barriers_re %>% filter(geo!=Inf) %>% select(`Geographical Barriers Sub-domain Score`,geo) %>% cor()
#barriers_re %>% filter(geo!=Inf) %>% ggplot(aes(x=`Geographical Barriers Sub-domain Score`,y=geo))+geom_point()

#barriers_re %>% filter(wider!=Inf) %>%  select(`Wider Barriers Sub-domain Score`,wider) %>% cor()
#barriers_re %>% filter(wider!=Inf) %>% ggplot(aes(x=`Wider Barriers Sub-domain Score`,y=wider))+geom_point()

# Living Environment Deprivation Domain             ----

variables <- c("LSOA code (2011)","Local Authority District code (2019)",
               "Housing in poor condition indicator",                                          
               "Houses without central heating indicator",                                     
               "Road traffic accidents indicator",                                             
               "Nitrogen dioxide (component of air quality indicator)",                        
               "Benzene (component of air quality indicator)",                                 
               "Sulphur dioxide (component of air quality indicator)",                         
               "Particulates (component of air quality indicator)",                            
               "Air quality indicator",
               "Living Environment Score", "Living Environment Score - exponentially transformed",                                                                       
               "Living Environment Rank (where 1 is most deprived)",                                                
               "Living Environment Decile (where 1 is most deprived 10% of LSOAs)",
               "Indoors Sub-domain Score",                                                                          
               "Indoors Sub-domain Rank (where 1 is most deprived)",                                                
               "Indoors Sub-domain Decile (where 1 is most deprived 10% of LSOAs)",                                 
               "Outdoors Sub-domain Score",                                                                         
               "Outdoors Sub-domain Rank (where 1 is most deprived)",                                               
               "Outdoors Sub-domain Decile (where 1 is most deprived 10% of LSOAs)")

living_re <- all_iod2019 %>%
  left_join(indicators) %>%
  select(one_of(variables)) %>%
  mutate(poor_housing_rank = rank(`Housing in poor condition indicator`)/n(),
         central_heating_rank = rank(`Houses without central heating indicator`)/n(),
         road_accd_rank = rank(`Road traffic accidents indicator`)/n(),
         nitrogen_rank = rank(`Nitrogen dioxide (component of air quality indicator)`)/n(),
         benzene_rank = rank(`Benzene (component of air quality indicator)`)/n(),
         sulphur_rank = rank(`Sulphur dioxide (component of air quality indicator)`)/n(),
         particulates_rank = rank(`Particulates (component of air quality indicator)`)/n(),
         air_rank = rank(`Air quality indicator`)/n(),
         
         poor_housing = qnorm(poor_housing_rank,mean = mean(poor_housing_rank),sd=sd(poor_housing_rank)),
         central_heating = qnorm(central_heating_rank,mean = mean(central_heating_rank),sd=sd(central_heating_rank)),
         
         indoors = poor_housing+central_heating,
         
         road_accd = qnorm(road_accd_rank),#,mean = mean(road_accd_rank),sd=sd(road_accd_rank)),
         nitrogen = qnorm(nitrogen_rank,mean = mean(nitrogen_rank),sd=sd(nitrogen_rank)),
         benzene = qnorm(benzene_rank,mean = mean(benzene_rank),sd=sd(benzene_rank)),
         sulphur = 0,#qnorm(sulphur_rank,mean = mean(sulphur_rank),sd=sd(sulphur_rank)),
         particulates = qnorm(particulates_rank,mean = mean(particulates_rank),sd=sd(particulates_rank)),
         air = qnorm(air_rank,mean = mean(air_rank),sd=sd(air_rank)),
         
         outdoors = road_accd+nitrogen+benzene+sulphur+particulates+air,
         
         indoors_subdomain = -23*log(1-(rank(indoors)/n())*(1-exp(-100/23))),
         outdoors_subdomain = -23*log(1-(rank(outdoors)/n())*(1-exp(-100/23))),
         
         living_score = (2/3*indoors_subdomain+1/3*outdoors_subdomain)
  )

living_re %>% filter(living_score!=Inf) %>% select(`Living Environment Score`,living_score) %>% cor()
living_re %>% filter(living_score!=Inf) %>% ggplot(aes(x=`Living Environment Score`,y=living_score))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)

#living_re %>% filter(indoors!=Inf) %>% select(`Indoors Sub-domain Score`,indoors) %>% cor()
#living_re %>% filter(indoors!=Inf) %>% ggplot(aes(x=`Indoors Sub-domain Score`,y=indoors))+geom_point()

#living_re %>% filter(outdoors!=Inf) %>% select(`Outdoors Sub-domain Score`,outdoors) %>% cor()
#living_re %>% filter(outdoors!=Inf) %>% ggplot(aes(x=`Outdoors Sub-domain Score`,y=outdoors))+geom_point()

# Crime Domain                                      ----

# No information published

# Index of Multiple Deprivation Score               ----

re_scores <- income_re[,c("LSOA code (2011)","income_score")] %>%
  left_join(employment_re[,c("LSOA code (2011)","employment_score")]) %>%
  left_join(education_re[,c("LSOA code (2011)","education_score")]) %>%
  left_join(health_re[,c("LSOA code (2011)","health_score")]) %>%
  left_join(barriers_re[,c("LSOA code (2011)","barriers_score")]) %>%
  left_join(living_re[,c("LSOA code (2011)","living_score")]) %>%
  #left_join(crime_re[,c("Data_Zone","crime_score")]) %>%
  mutate_at(vars(-`LSOA code (2011)`),function(x){-23*log(1-(rank(x)/n())*(1-exp(-100/23)))}) %>%
  mutate(iod = 0.30*income_score+0.20*employment_score+0.20*health_score+0.20*education_score+0.05*barriers_score+0.05*living_score) %>%
  left_join(all_iod2019) %>% rename(`Index of Multiple Deprivation` = `Index of Multiple Deprivation (IMD) Score`)

re_scores %>% select(`Index of Multiple Deprivation`, iod) %>% cor()
re_scores %>% ggplot(aes(x=`Index of Multiple Deprivation`,y=iod))+geom_point()+geom_abline(slope=1,intercept=0,colour="dodgerblue1",size=0.8)
