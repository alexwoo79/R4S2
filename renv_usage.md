# 项目环境使用说明（基于 renv）

## 一、首次使用（新设备/协作方）

### 项目环境配置步骤（本地执行，无需在文档中运行）

``` r
# 1. 安装 renv 包（使用清华镜像源，国内下载更快）
install.packages("renv", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")

# 2. 加载 renv 包
library(renv)

# 3. 初始化项目独立环境（确保当前工作目录是项目根目录）
renv::init()  

# 4. 安装 Quarto 所需的核心 R 包
install.packages(c("rmarkdown", "tidyverse"), repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")

# 5. 同步依赖到版本锁定文件
renv::snapshot()  

1. 下载项目文件夹（含所有文件，重点保留 `renv/`、`renv.lock`、`renv_init.R`）
2. 打开 R/RStudio，设置工作目录为项目根目录（File → Set Working Directory → Choose Directory）
3. 打开 `renv_init.R` 文件，全选代码并运行（自动安装 renv + 所有依赖包）
4. 运行完成后，即可直接执行项目脚本（如 `main.R`/`analysis.Rmd`）
```

## 二、日常开发（维护者/已初始化环境）

1. 共享项目资源：将整个项目文件夹复制给合作者，包括生成的`renv.lock`文件，以及`.Rprofile`和`renv/activate.R`。`renv.lock`记录了项目所需包的版本等关键信息，`.Rprofile`和`renv/activate.R`用于自动加载`renv`。

2. 更新锁文件（如有必要）：在项目进行过程中，若有人安装或更新了包，需运行`renv::snapshot()`更新`renv.lock`文件，然后将更新后的renv.lock文件再次共享给其他合作者，其他合作者重新运行`renv::restore()`即可同步新的包环境。