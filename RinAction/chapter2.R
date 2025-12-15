# 创建一个data.frame

# 每一列为一个向量

patientID <- c(1, 2, 3, 4)
age <- c(25, 34, 28, 52)
diabetes <- c('Type1', 'Type2', 'Type1', 'Type1')
status <- c('Poor', 'Improved', 'Excellent', 'Poor')
patient_data <- data.frame(patientID, age, diabetes, status)
patient_data
patient_data[1:2, ]
patient_data[1:2]
patient_data[c(1, 2)]
table(patient_data$diabetes, patient_data$status) # table统计分析

# attach,detach,with()

attach(mtcars)
summary(mpg)
plot(mpg, disp)
plot(mpg, wt)
detach(mtcars)

with(mtcars, {
  print(summary(mpg))
  plot(mpg, disp)
  plot(mpg, wt)
})


with(mtcars, {
  inside <- summary(mpg)
  outside <<- summary(mpg)
})
inside # Error !object 'inside' not found
outside # ok to show outside variable.


patient_data <- data.frame(
  patientID,
  age,
  diabetes,
  status,
  row.names = c('a', 'b', 'c', 'd')
)
row.names(patient_data)
patient_data

# 因子 factor
diabetes_f <- factor(diabetes)
diabetes_f
status <- factor(status, ordered = TRUE)
status
status_f <- factor(
  status,
  ordered = TRUE,
  levels = c('Poor', 'Improved', 'Excellent')
)
status_f


patient_data_f <- data.frame(
  patientID,
  age,
  diabetes_f,
  status_f,
  row.names = c('a', 'b', 'c', 'd')
)

str(patient_data_f)

summary(patient_data_f)


# R中没有多行注释
if (FALSE) {
  temp <- 1
}
# 上面的内容不执行。
temp


mydata <- data.frame(
  age = numeric(0),
  gender = character(0),
  weight = numeric(0)
)
