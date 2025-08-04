                             #1.Importing Dataset
install.packages("data.table")
library(data.table)
uds_Data <- fread("/data/uds_Data.csv", data.table = FALSE)
str(uds_Data)
length(unique(uds_Data$NACCID))       # There are 54025 unique participants


                         #2.Variable Grouping

# Demographic variables 
demo_vars <- c("NACCAGE", "SEX", "EDUC")

# Medical history 
medical_vars <- c("HYPERTEN", "DIABETES", "HYPERCHO", "CVHATT", "STROKE")

# Lifestyle variables
lifestyle_vars <- c("TOBAC30", "ALCOHOL", "NACCBMI")

# Family history
family_vars <- c("NACCFAM")

target_variable<-c("NACCALZD")

time<-c("VISITYR","VISITMO","VISITDAY")

id<-c("NACCID")

testInfo<-c("BPSYS","COGMODE","DEPD","MEMORY","ORIENT")


all_vars_stage1 <- unique(c(id,demo_vars, medical_vars, lifestyle_vars, family_vars,target_variable,time,testInfo))


df_stage1 <- uds_Data[, all_vars_stage1, drop = FALSE]


head(df_stage1)

#Function for printing variable destribution
print_variable_distribution <- function(df, variables) {
  for (var in variables) {
    cat("\n=== Variable:", var, "===\n")
    print(table(df[[var]], useNA = "ifany"))
  }
}


                                        #3. Data Cleaning

print_variable_distribution(df_stage1, colnames(df_stage1))


# 2. Handling missing/invalid values
num_df <- uds_Data[, sapply(uds_Data, is.numeric)]
num_df$NACCBMI[num_df$NACCBMI %in% c(-4, 888.8, 9.6, 9.9)] <- NA

df_valid <- num_df[!is.na(num_df$NACCBMI),]

# 3. Calculating correlation coefficient between BMI and variables 
cor_bmi <- sapply(df_valid, function(x) cor(df_valid$NACCBMI, x, use = "pairwise.complete.obs"))
cor_bmi_abs <- sort(abs(cor_bmi), decreasing = TRUE)
top_vars <- names(cor_bmi_abs[cor_bmi_abs > 0.2 & names(cor_bmi_abs) != "NACCBMI"])
print(top_vars)

# 4. Replace missing values (mice)
if (!require("mice")) install.packages("mice")
library(mice)

# Choose variables that have high correlation coefficient between each other.
df_sub <- uds_Data[, c("WEIGHT", "HEIGHT", "NACCBMI", "BPSYS", "BPDIAS")]

# Handling missing/invalid values
df_sub$NACCBMI[df_sub$NACCBMI %in% c(-4, 888.8, 9.6, 9.9)] <- NA
df_sub$BPSYS[df_sub$BPSYS %in% c(-4, 888, 999,777)] <- NA
df_sub$BPDIAS[df_sub$BPDIAS %in% c(-4, 888, 999)] <- NA

# Perform mice function (multiple mutatioin)
imp <- mice(df_sub, m = 5, maxit = 10, seed = 123)

# Generate a list of completed datasets from each imputation
imputed_list <- lapply(1:5, function(i) complete(imp, i))

# Calculate the average of each numeric variable across all 5 imputations
df_avg <- Reduce("+", imputed_list) / 5

#Replace NA with predicted values
df_stage1$NACCBMI <- df_avg$NACCBMI
df_stage1$BPSYS   <- df_avg$BPSYS
df_stage1$BPDIAS  <- df_avg$BPDIAS 
#///////////////////////////////////////////////////////////////////////////////


#6:Handling missing/invalid values
df_stage1 <- df_stage1[df_stage1$EDUC != 99, ]
cat("After EDUC filter:", nrow(df_stage1), "\n")

df_stage1 <- df_stage1[!df_stage1$BPSYS %in% c(60,68,69,232),]
cat("After BPSYS filter:", nrow(df_stage1), "\n")

df_stage1 <- df_stage1[!df_stage1$COGMODE %in% c(4,99),]
cat("After COGMODE filter:", nrow(df_stage1), "\n")

df_stage1 <- df_stage1[!df_stage1$DEPD %in% c(-4,9),]
cat("After DEPD filter:", nrow(df_stage1), "\n")

df_stage1 <- df_stage1[!df_stage1$MEMORY %in% c(99),]
cat("After MRMORY filter:", nrow(df_stage1), "\n")

df_stage1 <- df_stage1[!df_stage1$ORIENT %in% c(99),]
cat("After ORIENT filter:", nrow(df_stage1), "\n")

special_na_codes <- c(-4, 9)

vars <- c("HYPERTEN","NACCFAM", "DIABETES", "HYPERCHO", "CVHATT", "STROKE", "TOBAC30", "ALCOHOL")

for (var in vars) {
  df_stage1[[var]][df_stage1[[var]] %in% special_na_codes] <- NA
}

print_variable_distribution(df_stage1, colnames(df_stage1))

df_stage1_complete<-df_stage1

# Choose variables that have high correlation coefficient between each other.
impute_vars <- c("HYPERTEN", "DIABETES", "HYPERCHO", "CVHATT", "STROKE",
                 "TOBAC30", "ALCOHOL")

df_sub <- df_stage1_complete[, impute_vars]

# Replace missing/invalid values with NA
special_na_codes <- c(-4, 9, 888, 999, 777)
for (var in c("HYPERTEN", "DIABETES", "HYPERCHO", "CVHATT", "STROKE", "TOBAC30", "ALCOHOL")) {
  df_sub[[var]][df_sub[[var]] %in% special_na_codes] <- NA
}




# Perform mice function (multiple mutatioin)
imp <- mice(df_sub, m = 5, maxit = 10, seed = 123)

# Generate a list of completed datasets from each imputation
imputed_list <- lapply(1:5, function(i) complete(imp, i))

# Calculate the average of each numeric variable across all 5 imputations
df_avg <- Reduce("+", imputed_list) / 5

df_imputed <- complete(imp, 1)

# Create df_stage1_complete by adopting final handled values
for (var in impute_vars) {
  df_stage1_complete[[var]] <- df_imputed[[var]]
}
df_stage1_complete <- df_stage1_complete[!is.na(df_stage1_complete$NACCFAM), ]



# Result
cat("Number of rows in the original data:", nrow(df_stage1), "\n")
cat("Numebr of rows after removing missing values:", nrow(df_stage1_complete), "\n")

print_variable_distribution(df_stage1_complete, colnames(df_stage1_complete))

#///////////////////////////////////////////////////////////////////////////////

                          #Data Modification to bin to improve the accuracy of model

df_stage1_complete$HYPERTEN_BIN <- ifelse(df_stage1_complete$HYPERTEN == 0, 
                          0,
                          ifelse(df_stage1_complete$HYPERTEN %in% c(1, 2), 1, NA))

df_stage1_complete$DIABETES_BIN <- ifelse(df_stage1_complete$DIABETES == 0, 
                                          0,
                                          ifelse(df_stage1_complete$DIABETES %in% c(1, 2), 1, NA))

df_stage1_complete$HYPERCHO_BIN <- ifelse(df_stage1_complete$HYPERCHO == 0, 
                                          0,
                                          ifelse(df_stage1_complete$HYPERCHO %in% c(1, 2), 1, NA))

df_stage1_complete$CVHATT_BIN <- ifelse(df_stage1_complete$CVHATT == 0, 
                                          0,
                                          ifelse(df_stage1_complete$CVHATT %in% c(1, 2), 1, NA))

df_stage1_complete$ALCOHOL_BIN <- ifelse(df_stage1_complete$ALCOHOL == 0, 
                                          0,
                                          ifelse(df_stage1_complete$ALCOHOL %in% c(1, 2), 1, NA))


df_stage1_complete$NACCALZD <- ifelse(df_stage1_complete$NACCALZD %in% c(0, 8),
                                      0,
                                      1)

print_variable_distribution(df_stage1_complete, colnames(df_stage1_complete))


length(unique(df_stage1_complete$NACCID))

#///////////////////////////////////////////////////////////////////////////////

library(dplyr)
library(tidyr)

# 1. Create VISIT_DATE 
df_stage1_complete$VISIT_DATE <- with(
  df_stage1_complete, 
  as.Date(paste(VISITYR, VISITMO, VISITDAY, sep = "-"), format = "%Y-%m-%d")
)


# 2. Extract Two Most Recent Data from each Individual
df_2latest <- df_stage1_complete %>%
  group_by(NACCID) %>%
  filter(n() >= 2) %>%
  arrange(NACCID, desc(VISIT_DATE)) %>%
  mutate(visit_num = row_number()) %>%
  filter(visit_num <= 2) %>%
  ungroup()

# 3. Change into wide format
df_wide <- df_2latest %>%
  pivot_wider(
    id_cols = NACCID,
    names_from = visit_num,
    values_from = c(
      NACCAGE, STROKE, TOBAC30, NACCFAM,SEX,EDUC,
      HYPERTEN_BIN, DIABETES_BIN, HYPERCHO_BIN,
      CVHATT_BIN, ALCOHOL_BIN, NACCBMI, BPSYS,
      COGMODE, DEPD, MEMORY, ORIENT, NACCALZD,NACCBMI
    )
  )

# 4. Create Variable for a change (_delta)(Numerical:Difference / Categorical: Change Status)
df_wide <- df_wide %>%
  mutate(
    # Numerical Variables
    NACCAGE_delta   = NACCAGE_1 - NACCAGE_2,
    NACCBMI_delta   = NACCBMI_1 - NACCBMI_2,
    BPSYS_delta     = BPSYS_1 - BPSYS_2,
    COGMODE_delta   = COGMODE_1 - COGMODE_2,
    DEPD_delta      = DEPD_1 - DEPD_2,
    MEMORY_delta    = MEMORY_1 - MEMORY_2,
    ORIENT_delta    = ORIENT_1 - ORIENT_2,
    
    # Categorical Variables
    STROKE_delta        = as.integer(STROKE_1 != STROKE_2),
    TOBAC30_delta       = as.integer(TOBAC30_1 != TOBAC30_2),
    NACCFAM_delta       = as.integer(NACCFAM_1 != NACCFAM_2),
    HYPERTEN_BIN_delta  = as.integer(HYPERTEN_BIN_1 != HYPERTEN_BIN_2),
    DIABETES_BIN_delta  = as.integer(DIABETES_BIN_1 != DIABETES_BIN_2),
    HYPERCHO_BIN_delta  = as.integer(HYPERCHO_BIN_1 != HYPERCHO_BIN_2),
    CVHATT_BIN_delta    = as.integer(CVHATT_BIN_1 != CVHATT_BIN_2),
    ALCOHOL_BIN_delta   = as.integer(ALCOHOL_BIN_1 != ALCOHOL_BIN_2),
  
  )

df_final <- df_wide %>%
  select(-ends_with("_2"))  # Remove visit_2 (past) as it is used only for finding change

write.csv(df_final, "df_latest2.csv", row.names = FALSE)


df_stage1_complete %>%
  group_by(NACCID) %>%
  summarise(visit_count = n()) %>%
  count(visit_count) %>%
  arrange(desc(visit_count))

df_long <- df_stage1_complete %>%
  mutate(VISIT_DATE = as.Date(VISIT_DATE)) %>%  # DAte conversion
  arrange(NACCID, VISIT_DATE) %>%
  group_by(NACCID) %>%
  mutate(
    visit_num = row_number(),
    delta_days = as.numeric(VISIT_DATE - lag(VISIT_DATE)),
    delta_days = ifelse(is.na(delta_days), 0, delta_days)
  ) %>%
  ungroup()

# Filtering patients with 3 to 10 visits
valid_ids <- df_long %>%
  group_by(NACCID) %>%
  filter(n() >= 3 & n() <= 10) %>%
  distinct(NACCID)

# Filtering the main dataframe to include only valid IDs
df_filtered <- df_long %>%
  semi_join(valid_ids, by = "NACCID")

max_visits <- 10

# Creating a full sequence of visits for each valid NACCID
full_seq <- expand.grid(
  NACCID = valid_ids$NACCID,
  visit_num = 1:max_visits
)

# Left join to pad the dataframe with missing visits
library(dplyr)

df_padded <- full_seq %>%
  left_join(df_filtered, by = c("NACCID", "visit_num")) %>%
  group_by(NACCID) %>%
  arrange(visit_num, .by_group = TRUE) %>%
  mutate(
    mask = if_else(is.na(VISIT_DATE), 0L, 1L),  #L refers to integer type
    VISIT_DATE = if_else(mask == 0L, as.Date(NA), VISIT_DATE),
    delta_days = if_else(mask == 0L, 0, delta_days)
  ) %>%
  ungroup() %>%
  arrange(NACCID, visit_num)

# View the padded dataframe
print(df_padded)

df_padded <- df_padded %>%
  mutate(across(
    .cols = -VISIT_DATE,
    .fns = ~replace_na(., 0)
  ))

df_padded <- df_padded %>%
  mutate(VISIT_DATE = replace_na(VISIT_DATE, as.Date("1970-01-01")))

write.csv(df_padded, "df_timeseries_padded.csv", row.names = FALSE)


write.csv(df_stage1_complete, "df_cox_data.csv",  row.names = FALSE)