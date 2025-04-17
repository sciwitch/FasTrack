# FasTrack
Extract sequences from a Multi-FASTA file by their header line name.

This script is based on unix bash. 
Use it to extract multi-line spanning FASTA entries from a multi-FASTA file.

## Install:
Just download the script and make it executable via:
`chmod u+x fastrack.sh`

No dependencies are required on a UNIX machine.

## Usage:
Fasta headers (names) are either given as command-line input for only one entry or as a file of fasta-names (one entry per line).

`./fastrack.sh INPUT.fasta "SearchQuery" | QUERYLIST.txt`

The output will be printed on screen. So you probably want to redirect via something like:

`./fastrack.sh INPUT.fasta "SearchQuery" > OUTPUT.fasta`

## Example
Contents of a multi-FASTA file look like this, with a header (sequence name) beginning with ">" followed by nucleotide or amino acid sequence in the following lines.

```
>sequenceID-001 description
AAGTAGGAATAATATCTTATCATTATAGATAAAAACCTTCTGAATTTGCTTAGTGTGTAT
ACGACTAGACATATATCAGCTCGCCGATTATTTGGATTATTCCCTG
>sequenceID-002 description
CAGTAAAGAGTGGATGTAAGAACCGTCCGATCTACCAGATGTGATAGAGGTTGCCAGTAC
AAAAATTGCATAATAATTGATTAATCCTTTAATATTGTTTAGAATATATCCGTCAGATAA
TCCTAAAAATAACGATATGATGGCGGAAATCGTC
>sequenceID-003 description
CTTCAATTACCCTGCTGACGCGAGATACCTTATGCATCGAAGGTAAAGCGATGAATTTAT
CCAAGGTTTTAATTTG
```

Command:
`./fastrack.sh example.fasta "sequenceID-003"`
Will print:
```
>sequenceID-003 description
CTTCAATTACCCTGCTGACGCGAGATACCTTATGCATCGAAGGTAAAGCGATGAATTTAT
CCAAGGTTTTAATTTG
```
Same result with this command:
`./fastrack.sh example.fasta "ID-003 description"`

Command:
`./fastrack.sh example.fasta "sequenceID"`
Will print:
```
>sequenceID-001 description
AAGTAGGAATAATATCTTATCATTATAGATAAAAACCTTCTGAATTTGCTTAGTGTGTAT
ACGACTAGACATATATCAGCTCGCCGATTATTTGGATTATTCCCTG
```
**Note:** For performance reasons, only the first hit will be reported and the search will be aborted after that.
This makes it feasible to scroll through GB-sized fasta files and search for multiple sequences in seconds.

**Using a query file**
Given a query file "query.txt" that looks like this:
```
ID-001
ID-003
```
This command:

`./fastrack.sh example.fasta query.txt > out.fa`

Will create a new FASTA file looking like that:

```
>sequenceID-001 description
AAGTAGGAATAATATCTTATCATTATAGATAAAAACCTTCTGAATTTGCTTAGTGTGTAT
ACGACTAGACATATATCAGCTCGCCGATTATTTGGATTATTCCCTGTC
>sequenceID-003 description
CTTCAATTACCCTGCTGACGCGAGATACCTTATGCATCGAAGGTAAAGCGATGAATTTAT
CCAAGGTTTTAATTTG
```

## Why?
In bioinformatics we often spend a lot of time reformating incompatible file formats.
Unfortunately the FASTA-format is not very standardized in the way how many characters can be stored in a line.
Multi-FASTA files can consist of one sequence entry with 10000bp stored in a single line and another entry with 500bp stored across 10 lines of 50 characters each.
This unreliability makes it difficult to quickly obtain what you need from a multi-FASTA file.
Additionally we sometimes encounter datasets like in this zenodo archive [Metagenomic Immunoglobulin Sequencing (MIG-Seq)](https://doi.org/10.5281/zenodo.11154974) where the multi-FASTA file *"FF_genomeSetAlpha.fasta"*, containing multiple bacterial genomes concatenated after one another, has a file size of 11 GB.
Additional info which FASTA entry belongs to which original genome FASTA file is stored in the file *"FF_genomeSetAlpha.stb"*, looking like this:

```
COASSEMBLY_8037__NODE_44588_length_1988_cov_159.115123	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.259.fa
COASSEMBLY_8037__NODE_46193_length_1904_cov_21.099617	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.259.fa
COASSEMBLY_8037__NODE_47024_length_1865_cov_19.922819	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.259.fa
COASSEMBLY_8037__NODE_53381_length_1607_cov_96.412418	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.259.fa
COASSEMBLY_8037__NODE_54583_length_1566_cov_35.544661	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.259.fa
COASSEMBLY_8037__NODE_89_length_301076_cov_5.107100	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.27.fa
COASSEMBLY_8037__NODE_140_length_250557_cov_5.349513	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.27.fa
COASSEMBLY_8037__NODE_351_length_167585_cov_4.975559	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.27.fa
COASSEMBLY_8037__NODE_370_length_163718_cov_4.418550	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.27.fa
COASSEMBLY_8037__NODE_410_length_156112_cov_5.125324	METABAT215_SUBJECTMAPPING_SCAFFOLDS_min1500_COASSEMBLY_8037_1500_MERGED_77_METASPADES__.27.fa
```

In order to obtain single bacterial genomes from those two files one could run this command:

```
# extract multi-line fasta entries by fasta-header provided in a file
while IFS= read -r line; do
# uncomment the next line to run parallel jobs for each output.fasta file
#	( 
	# create a tmp file which holds all the contigs that need to go into this single fasta file
	grep "$line" FF_genomeSetAlpha.tsv | awk '{print $1}'> ${line}_entrylist;

	# gather all fasta entries defined in tmp and write them into a single fasta file
	./extract_fasta_entries.sh ${fasta} ${line}_entrylist > ${line}; 

	# clean up
	rm ${line}_entrylist
# uncomment the next line to run parallel jobs for each output.fasta file
#	) &
done < FF_genomeSetAlpha.stb
```
**NOTE**: This above code still ran 2 days on my machine. Better don't create this huge FASTA-files in the first place, if you can avoid it.





