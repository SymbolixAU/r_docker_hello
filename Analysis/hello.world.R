BASE_DIR <- getwd()

print("hello world from R")
print("hahaha! look at me!")
print("Boo!")
df <- read.csv(paste0(BASE_DIR, "/Data/input.csv"), header=TRUE)
df2 <- rbind(df,df)
write.csv(df2, paste0(BASE_DIR, "/Data/output.csv"))
