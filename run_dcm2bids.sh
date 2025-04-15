#!/bin/bash

# Run conda activate imaging first
# Watch out for \r character at end of line on mac - may need dos2unix
study_id=valev
study_path=/home/data/images/${study_id}
subject_file=${study_path}/code/valev_proc/dcm2bids.csv
config_file=${study_path}/code/valev_proc/dcm2bids_json_files/dcm2bids_config_${study_id}.json
echo $subject_file
{
read

while IFS=, read -r subj_num ses_id scan_id ; do
	echo "Reading Subject File: $subj_num $ses_id $scan_id "

	"$(dirname $0)"/dcm2bids_bic.sh -i $study_id -d $scan_id -p $subj_num -s $ses_id -c $config_file -m $study_path
	echo
done
} < ${subject_file}
