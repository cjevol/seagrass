############################################
################## ISOSeq ##################
############################################

# Transcriptomic Assembly - ISOSeq3
$ nohup ccs Specie.subreads.bam Specie.ccs.bam --min-rq 0.9 &
$ nohup lima Specie.ccs.bam Specie.primer.fasta Specie.fl.bam --isoseq &
$ nohup isoseq3 refine Specie.fl.BC2005_5p--BC2005_3p.bam Specie.primer.fasta Specie.flnc.bam --require-polya &
$ nohup isoseq3 cluster Specie.flnc.bam Specie.clustered.bam --verbose --use-qvs &
$ nohup lordec-correct -2 Specie_RNASeq_p0_1.fq.gz,Specie_RNASeq_p0_2.fq.gz -k 19 -s 3 -i Specie.clustered.hq.fasta.gz -o lordec_Specie.fasta -T 20 &

# Transcriptomic Assembly - Cogent
$ conda activate cogent_TXY
$ ln -s lordec_Specie.fasta isoseq_flnc.fasta
$ python /cDNA_Cupcake-28.0.0/cupcake2/tofu2/run_preCluster.py --cpus=20 
$ python /Cogent/generate_batch_cmd_for_Cogent_family_finding.py --cpus=20 --cmd_filename=cmd preCluster.cluster_info.csv preCluster_out bin
$ nohup bash cmd &
$ bash /cogent/check_all_bins_runs_completed.sh
$ printf "Partition\tSize\tMembers\n" > final.partition.txt
$ ls preCluster_out/*/*partition.txt | xargs -n1 -i sed '1d; $d' {} | cat >> final.partition.txt
$ grep -R '#unassigned:' preCluster_out | cut -d':' -f3 | tr ',' '\n' | sort -V -u |sed '1d' > preCluster_out.unassigned.ids
$ python /cDNA_Cupcake-28.0.0/sequence/get_seqs_from_list.py lordec_Poxyphyllus.fasta preCluster_out.unassigned.ids > unassigned.fasta
$ awk '/^>/&&NR>1{print "";}{printf "%s",/^>/?$0"\n":$0}' unassigned.fasta > preCluster_out.unassigned.fasta
$ sed -i '$s/$/\n/' preCluster_out.unassigned.fasta 
$ python /Cogent/generate_batch_cmd_for_Cogent_reconstruction.py /Specie/bin/ > batch_reconstruction_commands.sh
$ nohup bash batch_reconstruction_commands.sh &
$ bash check_all_reconstructions_runs_completed.sh
$ reconstruct_contig.py --nx_cycle_detection -k 40./ 
$ bash check_all_reconstructions_runs_completed.sh
$ cat bin/*/cogent2.renamed.fasta preCluster_out.unassigned.fasta preCluster_out.tucked.fasta preCluster_out.orphans.fasta> cogent_fakegenome.fasta
$ gmap_build -D . -d gmap_fakegenome cogent_fakegenome.fasta
$ gmap -D . -d gmap_fakegenome -f samse -n 0 -t 10 lordec_Specie.fasta > gmap_fakegenome.sam 2>gmap_fakegenome.sam.log
$ grep 'paths' gmap_fakegenome.sam.log |wc -l  
$ sort -k 3,3 -k 4,4n gmap_fakegenome.sam | grep -v '^@' > gmap_fakegenome.sort.sam
$ python /cDNA_Cupcake/cDNA_Cupcake-28.0.0/cupcake/tofu/collapse_isoforms_by_sam.py --input lordec_Specie.fasta -s gmap_fakegenome.sort.sam -c 0.6 -i 0.9 --dun-merge-5-shorter -o cogent_mapped 1>collapsed.log.txt 2>&1
$ python /cDNA_Cupcake/cDNA_Cupcake-28.0.0/cupcake/tofu/get_abundance_post_collapse.py cogent_mapped.collapsed Specie.clustered.cluster_report.csv
$ python /cDNA_Cupcake/cDNA_Cupcake-28.0.0/cupcake/tofu/filter_away_subset.py cogent_mapped.collapsed
  
# Transcriptomic Assembly - Gff
$ perl gtf2gff.pl ../cogent_mapped.collapsed.filtered.gff > tmp.gff3
$ perl extract-CDS-by-gff.pl tmp.gff3 ../cogent_fakegenome.fasta cogent_mapped_extractedGTFexons.fasta
$ TransDecoder.LongOrfs -t cogent_mapped_extractedGTFexons.fasta
$ TransDecoder.Predict -t cogent_mapped_extractedGTFexons.fasta
$ perl extract_longestCDS_GFF.pl cogent_mapped_extractedGTFexons.fasta.transdecoder.gff3 > cogent_mapped_extractedGTFexons.fasta.transdecoder.longestCDS.gff3
$ perl fix_exonOrientation2.pl tmp.gff3 cogent_mapped_extractedGTFexons.fasta.transdecoder.longestCDS.gff3 > tmp_orientCorrectedByCDS.gff3
$ perl extract-CDS-by-gff.pl tmp_orientCorrectedByCDS.gff3 ../cogent/cogent_fakegenome.fasta cogent_mapped_extractedGTFexons_orient.fasta  
$ perl combineGFFwithCDS_v3.pl tmp_orientCorrectedByCDS.gff3 cogent_mapped_extractedGTFexons.fasta.transdecoder.longestCDS.gff3 > combined.gff3
$ perl agat_convert_sp_gff2gtf.pl -gff combined.gff3 -o combined.gtf
$ python3 hisat2_extract_exons.py combined.gtf > combined.exons
$ python3 hisat2_extract_splice_sites.py combined.gtf > combined.splicesites

############################################
################## RNASeq ##################
############################################

# Filter - Fastp
$ nohup fastp -i Sample_R1.fastq.gz -o Sample_R1.clean.fastq.gz -I Sample_R2.fastq.gz -O Sample_R2.clean.fastq.gz -g -q 5 -u 50 -n 15 -l 150 --overlap_diff_limit 1 --overlap_diff_percent_limit 10 &
$ nohup perl filter_reads.pl Sample_R1.clean.fastq.gz Sample_R2.clean.fastq.gz & 

# Mapping - Hisat2
$ hisat2-build -p 20 Specie_fakegenome.fasta --ss combined.splicesites --exon combined.exons index
$ hisat2 -p 30 -x /Specie/FakeGenome/index -1 Sample_RNASeq_1_1.fq.gz -2 Sample_RNASeq_1_2.fq.gz -S Sample.sam 
$ samtools view -@ 30 -b -S Sample.sam > Sample.bam
$ samtools sort -@ 30 -o Sample.sort.bam Sample.bam
$ samtools view -@ 30 -f 0x2 -F 0x4 -F 0x8 -b Sample.sort.bam > Sample.flt.bam
$ samtools sort -@ 30 -n -o Sample.flt.sorted.bam Sample.flt.bam
$ samtools fixmate -@ 30 -m Sample.flt.sorted.bam Sample.flt.sorted.fix.bam
$ samtools sort -@ 30 -o Sample.flt.sorted.fix.sort.bam Sample.flt.sorted.fix.bam
$ samtools markdup -@ 30 Sample.flt.sorted.fix.sort.bam Sample.flt.sorted.fix.sort.markdup.bam
$ gatk AddOrReplaceReadGroups --INPUT Sample.flt.sorted.fix.sort.markdup.bam --OUTPUT Sample.flt.markdup.bam --RGPL ILLUMINA --RGSM Sample --RGID Sample --RGLB Sample --RGPU Sample
$ samtools index -@ 30 Sample.flt.markdup.bam

# SNP Calling - GATK
$ samtools faidx Sample_fakegenome.fasta
$ gatk CreateSequenceDictionary R=Specie_fakegenome.fasta O=Specie_fakegenome.dict
$ gatk HaplotypeCaller --input Sample.flt.markdup.bam --output Sample.everysites.g.vcf --reference Specie_fakegenome.fasta -ERC BP_RESOLUTION >Sample.gvcf.log 2>&1 
$ gatk CombineGVCFs --reference Specie_fakegenome.fasta --variant Sample1.everysites.g.vcf --variant Sample2.everysites.g.vcf --variant Sample3.everysites.g.vcf --output Specie_CombineGVCF.g.vcf >CombineGVCF.log 2>&1 
$ gatk GenotypeGVCFs --reference Specie_fakegenome.fasta --variant Specie_CombineGVCF.g.vcf --output Specie.GenotypeGVCFs.vcf.gz --include-non-variant-sites >GenotypeGVCFs.log 2>&1 
$ gatk SelectVariants -V Specie.GenotypeGVCFs.vcf.gz -select-type SNP -O Specie.gatkRawSNP.vcf.gz
$ gatk VariantFiltration -R Specie_fakegenome.fasta -V Specie.gatkRawSNP.vcf.gz -O Specie.gatkfilterSNP.vcf.gz --filter-name "filterQUAL" --filter-expression "QUAL < 25.0" --filter-name "filterQD" --filter-expression "QD < 2.5" --filter-name "filterFS" --filter-expression "FS > 60.0" --filter-name "filterSOR" --filter-expression "SOR > 6.0"

############################################
############# 1 to 1 OrthoGroup ############
############################################
$ orthofinder -f ./ -t 30 -a 20 &
$ nohup bash makedb.sh >makedb.log 2>&1 &  
#!/bin/bash
for i in $(cat 21078_OG_ID.txt);do makeblastdb -dbtype prot -input_type fasta -in /Orthogroup_Sequences/${i}.fa -out blastdb/${i}.blastdb;done
$ nohup bash blastp.sh >blastp.log 2>&1 & 
#!/bin/bash
for i in $(cat 21078_OG_ID.txt);do blastp -query /Orthogroup_Sequences/${i}.fa -db blastdb/${i}.blastdb -out blastp/${i}.blp.txt -num_threads 40 -outfmt " 6 qseqid qlen qstart qend sseqid slen sstart send evalue bitscore pident positive ";done  
$ nohup bash extractBestHit.sh >exactBestHit.log 2>&1 &
#!/bin/bash
for i in $(cat 21078_OG_ID.txt);do perl extractBestHit.pl blastp/${i}.blp.txt > blastp/${i}.bestHit.txt;done
$ nohup bash buildNetWork.sh >buildNetWork.log 2>&1 &
#!/bin/bash
for i in $(cat 21078_OG_ID.txt);do perl buildNetWork.pl blastp/${i}.bestHit.txt > blastp/${i}.netWork.txt;done
$ nohup bash createOrthAln.sh >createOrthAln.log 2>&1 &
#!/bin/bash
for i in $(cat 21078_OG_ID.txt);do perl createOrthAln.pl /Orthogroup_Sequences/${i}.fa blastp/${i}.netWork.txt;done


###########################################################
###### Inference of phylogenetic tree of Alismatales ######
###########################################################
###### 27Species Concatenation approaches ######
$ nohup bash mafft.sh >mafft.log 2>&1 &
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do mafft --thread 10 ${i}_27IndsProt.fasta > mafft/${i}_27Sp27IndsProt_mafft.fasta;done 
$ nohup bash trim.sh > trim.log 2>&1 &
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do trimal -in mafft/${i}_27Sp27IndsProt_mafft.fasta -out MafftTrim/${i}_27Sp27IndsProt_mafft_trim.fasta -gt 0.2 -st 0.001 -cons 85;done
# Rstudio 
install.packages("phylotools")
library(phylotools)
mafft<-list.files("27Sp27IndsProt_MafftTrim/")
dir<-paste("27Sp27IndsProt_MafftTrim/",mafft,sep = "")
dir_ma<-as.matrix(dir)
supermat(dir_ma)
Supermatrix "supermat.out.phy" and RAxML partition file "gene_partition.txt" have been saved
$ nohup iqtree2 -s 27Sp_27Inds_2079OG_Supermat.phy -p 27Sp_27Inds_2079OG_Partition.txt -m MFP -B 1000 -T 20 & 

###### 27Species coalescent approaches ######
$ nohup bash 1390_OG_IqtreeAstral.sh >1390_OG_IqtreeAstral.log 2>&1 &
#!/bin/bash
for i in $(cat 1390_OG_ID.txt);do iqtree2 -s IqtreeAstral/${i}_27Sp27IndsProt_mafft_trim.fasta -m MFP -B 1000 -T 40;done 
$ cat *.treefile > 27Sp_27Inds_1390OG_IqtreeAstral_input.tre
$ nohup java -jar astral.5.7.8.jar -i 27Sp_27Inds_1390OG_IqtreeAstral_input.tre -o 27Sp_27Inds_1390OG_IqtreeAstral.tre >astral.log 2>&1 &

###### Divergence time estimation ######
$ cd /mcmctree/1_mcmctree/
$ nohup /paml-4.10.7/bin/mcmctree my_mcmctree.ctl &
$ cp ./* /mcmctree/2_codeml/
$ cd /mcmctree/2_codeml/
$ nohup /paml-4.10.7/bin/codeml tmp0001.ctl &
$ cp rst2 ../3_mcmctree/in.BV
$ cd /mcmctree/3_mcmctree/
$ nohup /paml-4.10.7/bin/mcmctree my_mcmctree.ctl &


############################################
################### Ka/Ks ##################
############################################
###### pep to cds
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do python3 pep2cds.py /25Sp_2079_bestOrthAln/${i}_bestOrthAln.fasta 25Sp_all_cds 25Sp_25Inds_2079OG_CDS/${i}_25SpCDS.fasta;done

###### .paml
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do perl ParaAT.pl -a ${i}_simplify_pep.fa -n ${i}_simplify_cds.fa -h ${i}_simplify_homologous.txt -p proc -f paml -m mafft -o ${i}_paraat_output;done
$ nohup python3 rename_files.py paraat_output/ 2079_paraat_output/ &

###### .subtree
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do Rscript extract_subtree.R 25Sp_SimplyID_NoLenth.tre ${i}_species_list.txt ${i}_subtree.tre;done 
#!/bin/bash
for i in $(cat 2079_OG_ID.txt);do python3 treAddLine.py ${i}_species_list.txt ${i}_subtree.tre ${i}.tre;done 

###### Codeml Model0
$ nohup bash run_2079_model0.sh &
while read i; do
    cd /kaks_2079_OG/${i}/model0/
    /paml-4.10.7/bin/codeml model0_codeml.ctl
done < OG_ID.txt

###### Codeml Model1
$ nohup bash run_2079_model1 &
while read i; do
    cd /kaks_2079_OG/${i}/model1/
    /paml-4.10.7/bin/codeml model1_codeml.ctl
done < OG_ID.txt

###### Codeml Model4a
$ nohup bash model4aTreeLabel.sh >model4aTreeLabel.log 2>&1 &
#!/bin/bash
cd /kaks_2079_OG/
for i in $(cat OG_ID.txt);do 
cd /kaks_2079_OG/${i}/
mkdir model4a
python3 TreeLabelModel4a.py ${i}.tre model4a/${i}_model4a.tre;
done 
$ nohup bash run_2079_model4a &
while read i; do
    cd /kaks_2079_OG/${i}/model4a/
    /paml-4.10.7/bin/codeml model4a_codeml.ctl
done < OG_ID.txt