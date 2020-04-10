mkdir -p results/fastqc

fastqc data/*.fastq* -o results/fastqc

cd results/fastqc
cmd.exe /C start A0167105L_1_fastqc.html
cmd.exe /C start A0167105L_2_fastqc.html

for filename in *.zip; do
	unzip $filename
done

less A0167105L_1_fastqc/summary.txt
less A0167105L_2_fastqc/summary.txt

cd ../..
mkdir -p docs
cat results/fastqc/*/summary.txt > docs/fastq_summaries.txt

grep FAIL docs/fastq_summaries.txt #Returns empty: no fail reads, no need to trim

mkdir -p data/genome
cd data
mv sacCer3.fa genome
mv ty5_6p.fa genome
cd ..
mkdir -p results/sam results/bam results/bcf results/vcf

bowtie2-build data/genome/sacCer3.fa,data/genome/ty56p.fa data/genome/indexed_both

export BOWTIE2_INDEXES=$(pwd)/data/genome

for file in data/*1.fq ; do
    echo running file
    bowtie2 -x indexed_both \
         --very-fast -p 4\
         -1 data/A0167105L_1.fq \
         -2 data/A0167105L_2.fq \
         -S results/sam/A0167105L.sam
done

samtools view -b -F 1550 results/sam/A0167105L.sam > results/bam/samflags.bam
samtools sort results/bam/samflags.bam -o results/bam/samflags-sorted.bam
samtools view -h results/bam/samflags-sorted.bam > results/sam/samflags-sorted.sam

grep -i ty5 results/sam/samflags-sorted.sam

grep -i ty5 results/sam/samflags-sorted.sam |grep -i -w 42 > results/sam/grep-samflags-sorted.sam

grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 | cut -f3,4,7,8
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42  | cut -f3,4,7,8 > results/sam/grep1.txt

grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f3,7 | uniq -c > results/sam/grep2.txt

grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f3,4 | grep chrIV
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f3,4 | grep chrIX
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f3,4 | grep chrVIII
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f3,4 | grep chrXIV
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f7,8 | grep chrIV
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f7,8 | grep chrIX
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f7,8 | grep chrVIII
grep -i ty5 results/sam/samflags-sorted.sam | grep -i -w 42 |cut -f7,8 | grep chrXIV

samtools view -H results/bam/samflags-sorted.bam > results/sam/header.sam
cat results/sam/header.sam results/sam/grep-samflags-sorted.sam > results/sam/final.sam
cat results/sam/header.sam results/sam/grep-samflags-sorted.sam > results/sam/final.txt
samtools view -S -b results/sam/final.sam > results/bam/final.bam

mkdir results/bed

bedtools bamtobed -i results/bam/final.bam > results/bed/final.bed

grep -v TY5 results/bed/final.bed > results/bed/browser.bed
grep -i chrIV results/bed/browser.bed > results/bed/chrIV.bed
grep -i chrIX results/bed/browser.bed > results/bed/chrIX.bed
grep -i chrVIII results/bed/browser.bed > results/bed/chrVIII.bed
grep -i chrXIV results/bed/browser.bed > results/bed/chrXIV.bed

samtools index results/bam/final.bam
