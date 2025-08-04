# snu-bmi-alzheimer-prediction  
Alzheimer's disease risk prediction model developed during a research internship at the Seoul National University (SNU) Biomedical Informatics Lab.

## Project Overview

This project focuses on predicting the risk of Alzheimer's disease using longitudinal health records through data preprocessing, feature engineering, and machine learning techniques.

## Dataset

- **Source**: National Alzheimer’s Coordinating Center (NACC) Uniform Data Set (UDS)  
- **Key Variables**: Age, Sex, Stroke History, BMI, Cognitive Test Scores (Memory, Orientation), Blood Pressure, etc.  
- **Preprocessing**: Multivariate Imputation by Chained Equations (MICE), feature engineering, time series reshaping  

## Methods

- **Logistic Regression**: Baseline binary classification model  
- **Neural Network (Multilayer Perceptron)**: Nonlinear classification model  
- **Time Series Analysis** *(in progress)*: Sequential modeling of patient-level longitudinal features 

## Privacy Notice
- **Due to privacy concerns, real data cannot be uploaded.**  
  Instead, mock data is generated based on realistic ranges for each variable to perform tests and further study.
  
- **To access real data, please refer to [NACC's Data Request Process](https://naccdata.org/requesting-data/data-request-process).**


