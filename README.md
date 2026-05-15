# epu-index
This repository contains an R script for generating the EPU index HTML widget and a YAML script for (1) housing it and its underlying data in this repository and (2) creating a GitPages page URL.

PRODUCTS: The workflow will save (1) an HTML version of the widget to the repository's root directory, (2) a GitPages webpage of the widget to deployments, and (3) a CSV of the widget's/index's underlying data to the "clean" subfolder of the "Data" folder.

PATH REQUIREMENTS:
No changes to any directories/paths in the R or YAML scripts are necessary. The root of the YAML script (and thus of the R script) is the entire repository; please keep it that way to simplify the workflow.

DATA REQUIREMENTS:
The "toscrape" subfolder of the "Data" folder is where you must put the raw Newsbank txt files so that the R script can scrape them. The "clean" subfolder of the "Data" folder is where the workflow places the cleaned index data that underlies the index widget.
