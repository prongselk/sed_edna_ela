#!/bin/bash

blastn -task blastn -db /mnt/f/blast_db/nt \
       -query /mnt/e/sed_edna_ela/data/input/all_lengthfilter_zotus_4.fasta \
       -num_threads 4 \
       -evalue 0.0001 \
       -perc_identity 70 \
       -max_target_seqs 20 \
       -out /mnt/e/sed_edna_ela/data/blast_output/all_70_new.hits \
       -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore" 
