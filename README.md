# epu-index
This repository contains an R script for generating the EPU index HTML widget and a YAML script for (1) housing it and its underlying data in this repository and (2) creating a GitPages page URL.

PATH REQUIREMENTS:
No changes to any directories/paths in the R or YAML scripts are necessary. The root of the YAML script (and thus of the R script) is the entire repository; please keep it that way to simplify the workflow.

DATA REQUIREMENTS:
The "toscrape" subfolder of the "Data" folder is where you must put the raw Newsbank txt files so that the R script can scrape them. The "clean" subfolder of the "Data" folder is where the workflow places the cleaned index data that underlies the index widget.
