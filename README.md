## CapacityLossMatlab
A Semi-Empirical Model (SEM) for predicting the capacity loss of Lithium-ion batteries (LIBs) during cycling aging is used. This project is published in 35th ECMS International Conference on Modelling and Simulation.

**This repository contains MATLAB files and data to predict the capacity loss using SEM**

**Main Contributor**: [Mohamed Rabah](https://scholar.google.com/citations?user=3o2gS80AAAAJ&hl=en)

**Affiliation**: Turku University of Applied Sciences

## Paper and conference presentation
[CAPACITY LOSS ESTIMATION FOR LI-ION BATTERIES BASED ON A SEMI-EMPIRICAL MODEL](https://drive.google.com/file/d/1_XF3AHhH7OotMk2cxfh0bj4TYo9XtvD7/view?usp=share_link) and [Presentation](https://drive.google.com/file/d/1Nuwq555htsr8aBe7mBM1xWdjWc5LwC5w/view?usp=share_link) contains the explanations of the utilized model and the used data. 

## Requirements
Tested on MATLAB 2021b, 2022a.

## Model explanation
To test the feasibility of the proposed model, several LIB chemistries should be evaluated. In this work, two different chemistries of LIBs have been chosen; Lithium Iron Phosphate (LFP) and Lithium-Titanate Oxide (LTO). These chemistries are among the primary candidates for modern heavy-duty battery electric vehicles (HDBEV) systems.

The equation for calculating the capacity loss during cycling aging is as follow: 
$C{^{cyc}_{loss}} = B_{cyc}(I)\cdot e^{-\frac{E + \alpha \cdot |I|}{R(T-T_{ref})}} \cdot A{^{z_{cyc}}_h}$
$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$


The model flowchart shown in the below figure is divided into two parts; Data selection and fitting process which will be added later to this repository, and data validation which would be our main focus for now. 

![flowchart](flowchart.png)

### Data validation
For validating our data, 


