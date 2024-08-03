# SMS-RT

Iterative reconstruction code for Simultaneous Multi-Slice (SMS) Real-time Cardiac MRI for spiral golden-angle acquisition. 
A snapshot of this code used for paper can be seen here: 

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12727826.svg)](https://doi.org/10.5281/zenodo.12727826)


## Data

Shorter example SMS and Single-Band (SB) data acquired at ramped-down 0.55T are included in the directory. SB slices 2 (apical slice), 5 (mid slice), and 8 (basal slice) correspond to one SMS acquisition, each for ~ 2 seconds. The full acquisitions (~15 seconds) for these datasets can be found here: 

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12737931.svg)](https://doi.org/10.5281/zenodo.12737931)

The datasets contain the raw data for real-time cardiac MRI acquired at 0.55T scanner. The data is stored as a MATLAB struct: k-space contains the raw data [Nsample x Narms x Ncoil], and kspace_info contains relevant acquisition-related information.

## Usage

### Inputs: 

```SMS_flag = 1``` for the SMS data (encoding operation includes CAIPI term).

```weight_tTV``` and ```weight_sTV``` are the regularization parameters for the Spatiotemporally Constrained Reconstruction (STCR), which are set to the optimal parameters for this study. 

The solver is Non-linear Conjugate Gradient. ```ifGPU = 1``` uses the GPU for the iterative reconstruction. 


Set the relevant flags inside and run 

```
main.m
```

### Inputs: 

Iterative reconstruction returns resulting image series in ```Image_recon```. For SB, the output shape is [Nx x Ny x Nframes]; for SMS, the shape is [Nx x Ny x Nframes x Nslice]. 

### Notes:

The code is tested with MATLAB 2021a on a server equipped with 4x NVIDIA A100 GPU (40GB memory for each). May need to set ```ifGPU = 0``` for GPUs with memory <= 4GB or for no NVIDIA GPU case. 
