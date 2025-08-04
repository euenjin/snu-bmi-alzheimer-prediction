# Load necessary packages
library(data.table)
library(dplyr)
library(lubridate)
library(survival)

# Load the dataset
cox_Data <- fread("data/df_mock_cox_data.csv", data.table = FALSE)

# Check structure of dataset (column types, etc.)
str(cox_Data)

# Count number of unique patients
length(unique(cox_Data$NACCID))

# --- Filter Patients visit more than two times ---
patients_2plus <- cox_Data %>%
  group_by(NACCID) %>%
  filter(n() >= 2) %>%
  pull(NACCID) %>%
  unique()

cox_Data_2plus <- cox_Data %>%
  filter(NACCID %in% patients_2plus)

# Step 1: Identify patients without Alzheimer’s at their first visit 
first_visit <- cox_Data_2plus %>%
  group_by(NACCID) %>%
  filter(VISIT_DATE == min(VISIT_DATE)) %>%
  ungroup()

ids_without_event_at_first <- first_visit %>%
  filter(NACCALZD == 0) %>%
  pull(NACCID)

# Step 2: Keep only data for patients who were Alzheimer-free at first visit
cox_filtered <- cox_Data_2plus %>%
  filter(NACCID %in% ids_without_event_at_first)

# Step 3: Summarize each patient with:
cox_final <- cox_filtered %>%
  group_by(NACCID) %>%
  summarise(
    start_date = as.IDate(min(VISIT_DATE)),
    event = as.integer(any(NACCALZD == 1)),
    event_date = if (event == 1) as.IDate(min(VISIT_DATE[NACCALZD == 1])) else as.IDate(NA),
    last_date = if (event == 1) event_date else as.IDate(max(VISIT_DATE)),
    time = as.numeric(last_date - start_date)
  ) %>%
  ungroup()

# Summary statistics
nrow(cox_final)                    # Total number of patients
sum(cox_final$event == 1)         # Number of patients who developed Alzheimer's
sum(cox_final$event == 0)         # Number of patients who were censored (no Alzheimer's)
sum(is.na(cox_final$event_date))  # Should match number of non-Alzheimer cases


# 1. Extract feature values at their first visit
first_visit_features <- cox_Data_2plus %>%
  group_by(NACCID) %>%
  filter(VISIT_DATE == min(VISIT_DATE)) %>%
  ungroup() %>%
  select(-VISIT_DATE)  # VISIT_DATE is excluded as it is already included in cox_final

# 2. Use left join to include feature values at their first visit with cox_final 
cox_final_with_features <- cox_final %>%
  left_join(first_visit_features, by = "NACCID")


# Check Result
head(cox_final_with_features)


# Step 4: Save result as CSV file
write.csv(cox_final_with_features, "cox_fina.csv", row.names = FALSE)



