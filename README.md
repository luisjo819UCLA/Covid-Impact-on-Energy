
# Electricity Consumption Analysis for Energy Distribution Firms

## Project Overview

This repository provides a detailed analysis of electricity consumption data for energy distribution firms across various regions. The project processes time-series data to visualize and analyze electricity demand trends, applying techniques for data cleaning, handling missing values, and segmenting by time periods and geographic locations. 

## Objectives

1. **Data Import and Cleaning**: Load and preprocess the dataset for analysis, removing errors and imputing missing values.
2. **Data Transformation**: Adjust data points to normalize values and set limits based on business logic.
3. **Segmentation by Time and Region**: Segment data by pre- and post-pandemic periods and by regions for comparative analysis.
4. **Visualization and Reporting**: Generate visualizations to track consumption patterns and detect anomalies.

## Project Structure

This project uses **R** and relies on libraries such as `tidyverse`, `lubridate`, `imputeTS`, and `ggplot2` for data manipulation and visualization. 

### 1. Data Loading and Initial Inspection
- **Data Files**: 
  - `datos.RDS` includes primary consumption data.
  - `nombres.RDS` holds metadata for measurement points and departmental organization.
- **Initial Exploration**: Data from both files is sampled to provide an overview of measured points and regional organization.

### 2. Data Transformation
- **Time Adjustment**: Timestamps are adjusted to represent accurate measurement times by subtracting 30 minutes from each reading.
- **Segmentation**: Data is split into pre- and post-March 15, 2020 segments, corresponding to the impact of the COVID-19 pandemic on electricity usage.
- **Outlier Handling**: Outliers are capped based on median and standard deviation limits, and missing values are imputed using moving averages.

### 3. Regional Analysis
- **Tumbes and Lambayeque Regions**: Separate transformations and analyses are conducted for each region to explore regional demand patterns, with visualizations focusing on changes in consumption over time.
- **Other Departments**: Data is grouped into key departments based on pre-pandemic consumption, ensuring meaningful regional aggregation.

### 4. Visualization
- **Time-Series Plots**: Consumption trends are displayed over time, with individual facets for each measurement point, highlighting the demand trend for each region.
- **Anomaly Detection**: Points of unusually high consumption are highlighted using color-coded markers and ellipses.

### 5. Summary of Functions

- `limite(x)`: Caps values exceeding 300.
- `scale2(x)`: Caps values that exceed the median by four standard deviations.
- **Missing Value Imputation**: `na_ma()` and `na_seasplit()` methods fill in missing values using moving averages and seasonal splitting.

### Key Visualizations

- **Line Plots by Region**: Show time-series data for selected regions, highlighting significant shifts in demand.
- **Area Plots**: Illustrate cumulative demand per department, with a vertical marker for the pandemic's impact on March 15, 2020.
- **Anomaly Detection**: Areas with demand spikes above certain thresholds are highlighted, particularly for regions like Lambayeque.

## Key Libraries

- **Data Management**: `dplyr`, `lubridate`, `tidyverse`
- **Time-Series Handling**: `imputeTS`
- **Visualization**: `ggplot2`, `ggforce` for enhanced plot customization

## Files in Repository

- `main_script.R`: The main R script containing the full data pipeline, from loading and preprocessing to visualization.
- `.RDS` files: Data files containing raw time-series data and metadata for departmental information.

## Installation and Usage

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/your-repository.git
    cd your-repository
    ```

2. **Install Required Libraries**:
    ```R
    install.packages(c("tidyverse", "lubridate", "imputeTS", "openxlsx", "ggforce"))
    ```

3. **Run the Analysis**:
    Open `main_script.R` in an R environment and run each section to load, transform, and visualize the data.

## Results

The analysis reveals key trends in electricity consumption before and after the onset of the COVID-19 pandemic. The data visualizations illustrate regional demand shifts, as well as periods of high consumption, which are flagged and marked for further investigation.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

--- 

This README provides a structured overview of your energy data project, ensuring users can understand the project's purpose and how to run it effectively.
