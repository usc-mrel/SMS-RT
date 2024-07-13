# SMS-RT

Iterative reconstruction code for Simultaneous Multi-Slice (SMS) Real-time Cardiac MRI for spiral golden-angle acquisition. 
A snasphot of this code used for paper can be seen here: 

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12727826.svg)](https://doi.org/10.5281/zenodo.12727826)


## Data

Example SMS and Single-Band (SB) data acquired at ramped-down 0.55T can be found here: 

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12737931.svg)](https://doi.org/10.5281/zenodo.12737931)

contains the raw data for real-time cardiac MRI acquired at 0.55T scanner. The data is stored as a MATLAB struct: k-space contains the raw data [Nsample x Narms x Ncoil], and kspace_info contains relevant acquisition-related information.

## Usage

Set the relevant flags inside and run 

```
main.m
```
