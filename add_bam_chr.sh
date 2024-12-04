#!/bin/bash

# Check if the input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input.bam>"
    exit 1
fi

# Input BAM file
INPUT_BAM="$1"

# Output BAM file
OUTPUT_BAM="${INPUT_BAM%.bam}_addchr.bam"

# Temporary file for the modified header
TEMP_HEADER="modified_header.sam"

# Extract the header and modify it to add "chr" to the chromosome names
samtools view -H "$INPUT_BAM" | \
awk 'BEGIN {OFS="\t"} {
    if ($1 == "@SQ") {
        for (i=1; i<=NF; i++) {
            if ($i ~ /^SN:/) {
                sub(/^SN:/, "SN:chr", $i);  # Add "chr" prefix
            }
        }
    }
    print $0
}' > "$TEMP_HEADER"

# Use the modified header to create a new BAM file
samtools reheader "$TEMP_HEADER" "$INPUT_BAM" > "$OUTPUT_BAM" && samtools index "$OUTPUT_BAM"

# Clean up temporary file
rm -f "$TEMP_HEADER"

# Notify the user of the result
echo "Modified BAM file with 'chr' prefix created: $OUTPUT_BAM"
