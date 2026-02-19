# Sedimentary eDNA from ELA (CO1)

I tried to combine the relevant scripts and data into this repository. This is everything I've done to the data after completing my thesis and deciding to have another go at analysing the data from a different angle. 


## Step-by-step of what has been done by me

### Generating feature table with relative frequency from .fasta input

1. BLAST


I ran blast locally using this script ./scripts/bioinformatics/new_blast_script_70.sh against all of genbank. 
Percentage identity cut off was set at 70%. 

2. BASTA


I used BASTA to assign taxonomy to the sequences by infering one LCA for each query sequence of blast (against genbank). Percentage of best hits parameter was set at 85, so BASTA returns the taxonomy that is shared by at least 85% percentage of hits. See script ./scripts/bioinformatics/basta_script.sh 

3. Manual curation of taxonomy


All the metadata and the outputs of previous steps are stored here ./data/ELA_sediment.xlsx . This is an excel file built using the FAIRe format (see readme of excel for more info). 
!!NB the sheet taxaRaw contains the raw BASTA output and the *top hit* accession id and percentage identity from the blast output for this zOTU. These do not always match the corresponding taxonomic assignment from BASTA! Added just for reference. 
The sheet taxaFinal has been edited by me, with taxonomy corrected where possible. Any further edits to the taxonomic assignment (for example, there are some potentially marine species to double check), should be done in this file.
Just to note, as I've re-ran both blast and BASTA wuth different parameters, this taxonomic assignment list differs from what I'd used for my thesis.

**bonus** 

A krona plot can be generated using ./data/basta_output/curated_taxonomy_krona_format.txt and running the basta2krona.py script (if BASTA is installed). See plot ./data/basta_output/curated_krona.html

4. QIIME2


Then, the resulting taxonomic assignment is converted into a feauture table using the qiime2 q2-feature-table plugin. First, the output needs to be converted to .biom format and combined with feature table. See python script used for that here ./scripts/bioinformatics/generate_biom.py . See qiime2 script here ./scripts/bioinformatics/qiime2_script.txt . This includes opening a qiime2 visualisation that gives lots of useful metrics for the resulting frequency feature table. There is also commented out code in this file to generate a tree, which is not really useful at this stage. 
The resulting file can then be combined with taxonomy (with control samples removed as well). See ./scripts/generate_frequency_table_with_taxonomy.R


### Further analysis

From this point onwards, this is completely new analysis unrelated to what I did for my thesis. The idea is to contruct an HMSC model using presence-absence sed eDNA data and environmental variables. See ./scripts/000_hmsc.R for more information. There are a lot of ways to approach this and a lot of possibilities. The main question is what should be the granularity of the eDNA data. Should we use species-level identifications, a higher taxonomic rank, combine zOTUs into groups (trophic level? taxonomy?), or use the unique zOTUs themselves as a point of analysis (= track changes in presence/absence **of zOTUs*, not species, with changes in the environment). The environmental data also has a lot more blanks the further in the past you go, so it might be a good idea to split the data into time period chunks with different levels of detail available. 


### Note on lake experiments 

See script ./scripts/generate_ela_manipulation_timeline.R to see a plot of manipulations and observations over the years in the sampled lakes. 