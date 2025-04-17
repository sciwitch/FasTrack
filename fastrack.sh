#!/bin/bash
#
# Author:		Lena Best
# Last modified:	2018-12-07
#
# this script extracts multi-line spanning fasta entries from a mixed/multi fasta file
# fasta names/headers are either given as command-line input for only one entry or as a file of fasta-names (one entry per line)
#
# Usage:
# fastrack.sh      INPUT.fasta     "SearchQuery" | QUERYLIST.txt
# 
# Output will be printed on screen.
# You probably want to redirect via something like: ' > OUTPUT.fasta '.
#
#

_my_fasta="$1"
_my_query="$2"


# check if fasta file exists
if [ ! -f "${_my_fasta}" ]; then
	echo "The fasta file '${_my_fasta}' was not found!"
	echo -e "\nUsage:\n${0}\tINPUT.fasta\t\"SearchQuery\" | QUERYLIST.txt\n\nOutput will be printed on screen.\nYou probably want to redirect via something like: ' > OUTPUT.fasta '.\n"
	exit 1
fi

# check if query-file exists and if not assume that the second argument passed to this script
# would be a single fasta-name which should be found in the input
if [ ! -f "${_my_query}" ]; then
	if [ -n "${_my_query}" ]; then
		echo "Query given is not a file and will thus be treated as a single search key!"
		_my_queryFile=false
	else
		echo "No search key or key-file given! Will abort now."
		exit 2
	fi
else
	_my_queryFile=true
fi


# use stream editor to print all lines between search-pattern and following fasta-entry denoted by a
# leading '>'
# quit after reporting first match
function _my_getFastaEntry {
	_my_searchQuery="$1"
	#sed -n -e "/${_my_searchQuery}/,/\>/ p" "q" ${_my_fasta}
	sed -n -e "/${_my_searchQuery}/{p; :loop n; />/q; p; b loop}" ${_my_fasta}
}


# look up only one entry:
if [ "${_my_queryFile}" = false ]; then
#	echo "looking up ${_my_query}"
	_my_getFastaEntry "${_my_query}"
# look up complete list of entries - provided in a file
else
	while IFS= read -r line; do
#		echo "looking up ${line}"
		_my_getFastaEntry "${line}"
	done < "${_my_query}"
fi



# That's all we're done
exit 0



