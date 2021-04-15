# import data
qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path manifest.tsv --output-path sequences --input-format SingleEndFastqManifestPhred33V2

# data validation
qiime tools validate sequences.qza

# demultiplex & qc
qiime demux summarize --i-data sequences.qza --o-visualization sequences

# feature table construction (dada2)
qiime dada2 denoise-single --i-demultiplexed-seqs sequences.qza --p-trim-left 33 --p-trunc-len 180 --o-representative-sequences rep-seqs.qza --o-table table.qza --o-denoising-stats stats.qza

# check how many reads have passed the filter and are clustered
qiime metadata tabulate --m-input-file stats.qza --o-visualization stats.qzv

# visualize gzv file
qiime tools view stats.qzv

# feature table summary
qiime feature-table summarize --i-table table.qza --o-visualization table.qzv --m-sample-metadata-file sample-metadata.tsv

# map feature ids to sequences
qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv


# use pretrained classifier to cluster OTUs 
qiime feature-classifier classify-sklearn --i-classifier gg-13-8-99-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza
# create visualization
qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv

# qiime tools view taxonomy.qzv
# create barplot ? 
qiime taxa barplot \
    --i-table table.qza \
    --i-taxonomy taxonomy.qza \
    --m-metadata-file sample-metadata.tsv \
    --o-visualization taxa-bar-plots.qzv

qiime tools view taxa-bar-plots.qzv

# ===============================
# run metaphlan...
metaphlan G12_assembly.fna.gz --input_type fasta --nproc 4 > metaphlan_output.txt

# should download samples from HMP
# then run metaphlan on each of them
cd metaphlan_HMP
for f in *.fasta
    do
        metaphlan $f --input_type fasta --nproc 8 > ${f%.fasta}_profile.txt
    done
cd ../

# merge metaphlan tables
merge_metaphlan_tables.py metaphlan_output.txt metaphlan_HMP/*profile.txt > metaphlan_merged.txt

# generate species only abundance table
grep -E "s__|clade" metaphlan_merged.txt | sed 's/^.*s__//g' | cut -f1,3-9 | sed -e 's/clade_name/body_site/g' > metaphlan_merged_species.txt

# then rename columns using padnas 
# and turn up a heat(map)!
hclust2.py --log_scale --ftop 50 --f_dist_f braycurtis --s_dist_f braycurtis --max_flabel_len 100 --max_slabel_len 100 --cell_aspect_ratio 0.5 --dpi 300 -i metaphlan_merged_sp_edited.txt -o heatmap

# graphlan



# ==== alignment =====
# will be using hisat2
# build index
hisat2-build T_forsythia_genome.fasta T_forsythia_genome  

# align
hisat2 -x T_forsythia_genome -U G12_assembly.fna -f -S G12_aligned_hisat2.sam
samtools view -Sb G12_aligned_hisat2.sam | samtools sort -@ 8 > G12_aligned_hisat2.bam 
# 1% aligned... hmmmmm

# lets try bwa mem
bwa index T_forsythia_genome.fasta 
bwa mem -t 8 T_forsythia_genome.fasta G12_assembly.fna | samtools view -Sb | \
    samtools sort -@ 8 > G12_aligned_bwamem.bam
# still 1% aligned... so it's because some reads emerge from different species
# and not because HISAT2 miserably failed

# index EVERYTHING
samtools index *.bam


# find new regions - using pybedtools
# dump them into IGV
# seems like that's it

# fruitless attempts to annotate .bed file...
gff2bed --input=gff T_forsythia_annotation.gff3 -> T_forsythia_annotation.bed 
gff2bed < T_forsythia_annotation.gff3 > T_forsythia_annotation.bed
bedmap --echo-map-id new_features.bed T_forsythia_annotation.bed > new_features_anno.bed


