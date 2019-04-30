# Compound Annual Growth Rate for Software

[![DOI](https://zenodo.org/badge/2655008.svg)](https://zenodo.org/badge/latestdoi/2655008)

This repository contains the reproducibility package (software and data)
for the following paper.

Les Hatton, Diomidis Spinellis, and Michiel van Genuchten.
The long-term growth rate of evolving software:
Empirical results and implications.
*Journal of Software: Evolution and Process*, 29(5), May 2017.
[doi:10.1002/smr.1847](http://dx.doi.org/10.1002/smr.1847)

## Data Collection

Switch to the `tools` directory
```sh
cd tools
```

### Clone all repositories
```sh
./all-clone
```
This will create a directory under `$HOME/data` with about 127GB of
(bare) project repositories.

### Count lines of code at successive points of time
```sh
./all-measure
```
This will populate the `../data` directory with CSV files containing,
for every downloaded repository, a list of dates and
the corresponding lines of code at that date.
Here is an example.
```
1993-05-24,328082
1993-06-24,329586
1993-07-24,332544
```

If you want to avoid the download and measurement step,
the `data` directory is also supplied pre-populated with the CSV files.


## Analysis

### Count all the lines
Switch to the `tools` directory
```sh
cd tools
```

Construct a single `.csv` file by searching all the `.csv` files under `data/`

```sh
./get_alllines.sh  ../analyses/alllines.csv
```

Get a summary of the contributing projects.
```sh
./count_lines.pl   -c ../analyses/alllines.csv
```

This will give you the following.

```
Number of packages          = 7792
Total maxlines of code      = 932743070
Total last lines of code    = 868520506
Number empty                = 3182
Number empty at end         = 68
Number refactored           = 2030
```

### To calculate the growth data
```sh
./run_growth.sh
```
This takes a few minutes but reads all the raw .csv files and produces
an output .csv file with all growth data suitably edited for corruptions.
It then runs calc_growth.pl to extract growth rates, prepares some datafiles
and then runs R using tools/analysis_growth.R to extract the final results.

Details of what it did are placed in `../analyses/summary.dat` and
`../analyses/growth_results.txt`.

### To compare the open and closed source data.
```sh
./run_wilcox.sh
```

This compares the distributions of the open source data set with the closed
source impact column data, (currently 9 data points).
