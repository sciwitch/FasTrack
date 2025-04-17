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

Given a Query-File "query.txt" that looks like this:
```
ID-001
ID-003
```
This command:
`./fastrack.sh example.fasta query.txt > out.fa`

Will create a new FASTA file with this content:
```
>sequenceID-001 description
AAGTAGGAATAATATCTTATCATTATAGATAAAAACCTTCTGAATTTGCTTAGTGTGTAT
ACGACTAGACATATATCAGCTCGCCGATTATTTGGATTATTCCCTGTC
>sequenceID-003 description
CTTCAATTACCCTGCTGACGCGAGATACCTTATGCATCGAAGGTAAAGCGATGAATTTAT
CCAAGGTTTTAATTTG
```




