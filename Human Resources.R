getwd()
setwd("C:/Users/shreya gupta/Downloads")

# Importing Data sets
hr_train = read.csv("hr_train.csv")
hr_test = read.csv("hr_test.csv")

dim(hr_train)
dim(hr_test)

# Adding new column
hr_test$left = NA
hr_train$data = 'train'
hr_test$data = 'test'

# Combining Data
all_hr_data = rbind(hr_train,hr_test)
str(all_hr_data)  


library(dplyr)
library(car)
library(randomForest)
library(tree)
library(pROC)
sum(is.na(hr_train))
colSums(is.na(hr_train))

# Number of unique values of each column
apply(all_hr_data,2,function(x) length(unique(x)))

# Converting salary and sales into factor
all_hr_data = all_hr_data %>% 
  mutate(
    sales = as.factor(sales),
    salary = as.factor(salary)
  )

glimpse(all_hr_data)

# Creating Dummies 
CreateDummies=function(data,var,freq_cutoff=100){
  t=table(data[,var])
  t=t[t>freq_cutoff]
  t=sort(t)
  categories=names(t)[-1]
  
  for( cat in categories){
    name=paste(var,cat,sep="_")
    name=gsub(" ","",name)
    name=gsub("-","_",name)
    name=gsub("\\?","Q",name)
    name=gsub("<","LT_",name)
    name=gsub("\\+","",name)
    name=gsub(">","GT_",name)
    name=gsub("=","EQ_",name)
    name=gsub(",","",name)
    name=gsub("/","_",name)
    data[,name]=as.numeric(data[,var]==cat)
  }
  
  data[,var]=NULL
  return(data)
} 

glimpse(all_hr_data)

table(hr_train$promotion_last_5years)

# Convert Work_accident and promotions_last_5years into factors.
all_hr_data$Work_accident = as.factor(all_hr_data$Work_accident)
all_hr_data$promotion_last_5years = as.factor(all_hr_data$promotion_last_5years)

glimpse(all_hr_data)

# Remove extra variable that we added before.
hr_train = all_hr_data %>% filter(data == 'train') %>% select(-data) 
hr_test= all_hr_data %>% filter(data == 'test') %>% select(-left, -data) 

# Model Building
set.seed(2)
# Splitting of data
s=sample(1:nrow(hr_train),0.80*nrow(hr_train))
train_80=hr_train[s,] 
test_20=hr_train[-s,] 

# Decision Tree Model
tree_model = tree(left ~., data = train_80)
test_score = predict(tree_model,newdata = test_20,type = 'vector')
pROC::roc(test_20$left,test_score)
#------>AUC of DT 0.8347<-----------

# Random Forest Model
rf_model = randomForest(left ~., data = train_80)
test_score = predict(rf_model,newdata = test_20,type = 'response')
pROC::roc(test_20$left,test_score)

# Predictions on test data
fit_hr= randomForest(as.factor(left)~.,data=hr_train)
fit_hr
score=predict(fit_hr,newdata= hr_test, type="prob")[,2]
write.csv(score,'Shreya_Gupta_P4_part2.csv',row.names = F)




