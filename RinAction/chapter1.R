# 用于管理R工作空间的函数

getwd() # 获取当前工作目录
# setwd('RinAction/')
# 设置工作目录为RinAction文件夹
list.files() # 列出当前工作目录下的文件和文件夹
ls() # 列出当前工作空间中的对象
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")) # 设置CRAN镜像源为清华大学
# 显示当前R会话的选项设置
sessionInfo()
help.start()
history(25)
savehistory("my_history.Rhistory") # 保存历史命令到指定文件
loadhistory("my_history.Rhistory") # 从指定文件加载历史命令
save.image("my_workspace.RData") # 保存当前工作空间到指定文件
save(data, file = 'data.RData') # 保存指定对象到文件
load("my_workspace.RData") # 从指定文件加载工作空间
rm(data) # 删除指定对象
rm(list = ls()) # 删除工作空间中的所有对象
q() # 退出R会话
dir.create("new_folder") # 创建新文件夹
file.create("new_file.txt") # 创建新文件
file.rename("new_file.txt", "renamed_file.txt") # 重命名文件
file.remove("renamed_file.txt") # 删除文件
file.copy("source_file.txt", "destination_file.txt") # 复制文件
file.exists("destination_file.txt") # 检查文件是否存在
file.info("destination_file.txt") # 获取文件信息
list.dirs() # 列出所有子目录
file.path("folder", "subfolder", "file.txt") # 构建文件路径

# RinAction/chapter1.R

options()
options(digits = 4) # 设置数字显示精度为4位
getOption("digits") # 获取当前数字显示精度设置
getOption("repos") # 获取当前CRAN镜像源设置

x <- runif(20)
x
summary(x) # 显示x的摘要统计信息
hist(x)
p <- plot(density(x)) # 绘制x的密度图
png("histogram.png") # 打开PNG设备
sink()
dev.off() # 关闭图形设备

attach(mtcars)
lm(mpg ~ wt)
lmfit <- lm(mpg ~ wt)
summary(lmfit)
plot(lmfit)


# 使用一个新的包
install.packages('vcd')
help(package = 'vcd')
library(vcd)
Arthritis
example(Arthritis)
example(mtcars)
