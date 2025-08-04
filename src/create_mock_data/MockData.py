import numpy as np
import pandas as pd

# Set random seed for reproducibility
np.random.seed(42)

n_samples = 1000  # Number of samples

# Generate variables according to given specifications:

# Age at visit: integer between 18 and 110
NACCAGE = np.random.randint(18, 111, n_samples)

# Sex: 0 = Male, 1 = Female
SEX = np.random.choice([0, 1], n_samples)

# Years of education: 0 to 31
EDUC = np.random.randint(0, 32, n_samples)

# Binary variables (0 or 1)
STROKE = np.random.choice([0, 1], n_samples)
TOBAC30 = np.random.choice([0, 1], n_samples)
NACCFAM = np.random.choice([0, 1], n_samples)
HYPERTEN_BIN = np.random.choice([0, 1], n_samples)
DIABETES_BIN = np.random.choice([0, 1], n_samples)
HYPERCHO_BIN = np.random.choice([0, 1], n_samples)
CVHATT_BIN = np.random.choice([0, 1], n_samples)
ALCOHOL_BIN = np.random.choice([0, 1], n_samples)

# Binary delta variables (0 = no change, 1 = change)
# Assuming 30% chance of change
STROKE_delta = np.random.choice([0, 1], n_samples, p=[0.7, 0.3])
TOBAC30_delta = np.random.choice([0, 1], n_samples, p=[0.7, 0.3])
NACCFAM_delta = np.random.choice([0, 1], n_samples, p=[0.7, 0.3])
HYPERTEN_BIN_delta = np.random.choice([0, 1], n_samples, p=[0.7, 0.3])
HYPERCHO_BIN_delta = np.random.choice([0, 1], n_samples, p=[0.7, 0.3])

# Numeric continuous variables
NACCBMI = np.random.randint(10, 101, n_samples)  # BMI between 10 and 100

# Systolic blood pressure between 70 and 230
BPSYS = np.random.randint(70, 231, n_samples)

# Cognitive and mental state scores (0.0 to 3.0 with 0.5 steps)
def generate_cognitive_scores(size):
    return np.random.choice([0.0, 0.5, 1.0, 2.0, 3.0], size)

MEMORY = generate_cognitive_scores(n_samples)
ORIENT = generate_cognitive_scores(n_samples)

# Cognitive mode: 0 to 4
COGMODE = np.random.choice([0, 1, 2, 3, 4], n_samples)

# Delta versions of cognitive scores 
MEMORY_delta = np.random.choice([0,0.5,1,2,3], n_samples, p=[0.3, 0.2, 0.2, 0.2, 0.1])
ORIENT_delta = np.random.choice([0,0.5,1,2,3], n_samples, p=[0.3, 0.2, 0.2, 0.2, 0.1])
COGMODE_delta = np.random.choice([0,0.5,1,2,3], n_samples, p=[ 0.3, 0.2, 0.2, 0.2, 0.1])

# Construct DataFrame
df = pd.DataFrame({
    "NACCAGE": NACCAGE,
    "SEX_female": SEX,  
    "EDUC": EDUC,
    "STROKE": STROKE,
    "TOBAC30": TOBAC30,
    "NACCFAM": NACCFAM,
    "HYPERTEN_BIN": HYPERTEN_BIN,
    "DIABETES_BIN": DIABETES_BIN,
    "HYPERCHO_BIN": HYPERCHO_BIN,
    "CVHATT_BIN": CVHATT_BIN,
    "ALCOHOL_BIN": ALCOHOL_BIN,
    "STROKE_delta": STROKE_delta,
    "TOBAC30_delta": TOBAC30_delta,
    "NACCFAM_delta": NACCFAM_delta,
    "HYPERTEN_BIN_delta": HYPERTEN_BIN_delta,
    "HYPERCHO_BIN_delta": HYPERCHO_BIN_delta,
    "NACCBMI": NACCBMI,
    "BPSYS_delta": np.random.choice([0,1], n_samples, p=[0.7,0.3]),
    "COGMODE_delta": COGMODE_delta,
    "MEMORY_delta": MEMORY_delta,
    "ORIENT_delta": ORIENT_delta,
    "ORIENT": ORIENT,
    "COGMODE": COGMODE,
    "MEMORY": MEMORY,
    "BPSYS": BPSYS
})

# Save generated mock data to CSV file
df.to_csv('mock_alzheimer_data.csv', index=False)

