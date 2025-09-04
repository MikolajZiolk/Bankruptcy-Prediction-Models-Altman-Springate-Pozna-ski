# Bankruptcy Prediction Models: Altman, Springate, Poznański, and a Polish LDA Approach  

## Project Description  
This project focuses on **credit risk assessment** and **bankruptcy prediction** using classical discriminant analysis models and a newly built Polish model. The study evaluates how well these models perform on a dataset of Polish companies and explores the limitations of applying traditional bankruptcy prediction tools in modern contexts.  

The models considered include:  
- **Altman Z-Score**  
- **Springate Model**  
- **Poznański Model**  
- **Polish LDA-based Model** (developed as part of this project)  

## Methodology  
1. **Data Preparation**  
   - Dataset: 7027 firms with 65 variables.  
   - Missing values imputed with column means.  
   - Random sample: 100 bankrupt and 100 surviving firms for analysis.  

2. **Classical Models**  
   - **Altman Z-Score**:  
     - Z = 1.2X1 + 1.4X2 + 3.3X3 + 0.6X4 + 0.99X5  
     - Accuracy: **35.56%**, Type I error: **51%**, Type II error: **36%**.  
   - **Springate Model**:  
     - Accuracy: **39%**, Type I error: **73%**, Type II error: **49%**.  
   - **Poznański Model**:  
     - Accuracy: **48%**, Type I error: **100%**, Type II error: **4%**.  

3. **Polish LDA Model**  
   - Built using Linear Discriminant Analysis (LDA) with the same variables.  
   - Assumptions of normality and homogeneity of covariance not fully met.  
   - Accuracy: **13–16%**, showing very weak predictive power.  
   - Variable weights differ significantly from the Altman model, suggesting different financial structures in Polish firms.  

## Results & Insights  
- None of the classical models achieved satisfactory accuracy on the Polish dataset.  
- The **Poznański model** had the highest accuracy (48%) but failed completely in detecting bankrupt firms (100% Type I error).  
- The **Altman and Springate models** also showed poor predictive power.  
- The **Polish LDA model** highlighted differences in variable importance but was not reliable due to low accuracy.  
- Conclusion: **Traditional models are poorly adapted to Polish firms in this dataset and time horizon.** Longer time frames or alternative approaches may be required.  
