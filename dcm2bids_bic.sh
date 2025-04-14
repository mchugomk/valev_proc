#!/bin/bash

## Run dcm2bids for a single subject

study_dir=""		# initialize study dir
config_file=""		# initialize config file

## Process command line arguments
usage(){ echo "Usage: `basename $0` -i <study id> -d <source_participant_dir> -p <participant_id> -s <session_id> -c <config_file> -m <study_dir>
Run dcm2bids for a single participant

i:	study id
d:	directory containing single participant raw data for dcm2bids
p:	participant id for bids 
s:	session id for bids
c:	optional json config file for dcm2bids 
m:	optional main study directory from dcm2bids_setup.sh

Example: `basename $0` -i rto -d RTO_300_1_181298 -p 300 -s 01 -c dcm2bids_json_files/rto/dcm2bids_config_rto.json -m /data/analysis/maureen/rto 
" 1>&2; exit 1; }

if [ $# -lt 8 ]; then
	usage
fi
	
while getopts "i:d:p:s:c:m:" opt; do
    case "${opt}" in
    	i)	
    		study_id=${OPTARG}
    		;;
    		
        d)
            source_participant_dir=${OPTARG}
            ;;
        p)
            participant_id=${OPTARG}
            ;;
        s)
            session_id=${OPTARG}
            ;;
        c)
        	config_file=${OPTARG}
        	;;
        m)	
        	study_dir=${OPTARG}
        	;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


## Set study specific folders and files
if [ "$study_dir" = "" ]; then
	study_dir=/home/data/images/${study_id}
fi

data_dir=${study_dir}								# main data directory for sourcedata and bids output
bids_dir=$data_dir									# bids data directory # /bids_data
sourcedata_dir=$data_dir/sourcedata					# directory with raw imaging files (e.g. IMA)

if [ "$config_file" = "" ]; then
	config_file=dcm2bids_json_files/${study_id}/dcm2bids_config_${study_id}.json	# default config file for specified study
fi

## Check inputs
if [ ! -d $data_dir ]; then
	echo "Data directory $data_dir does not exist"
	exit 1
fi
if [ ! -d $bids_dir ]; then
	echo "BIDS data directory $bids_dir does not exist"
	exit 1
fi
if [ ! -d $sourcedata_dir/$source_participant_dir ]; then
	echo "Source data directory $sourcedata_dir/$source_participant_dir does not exist"
	exit 1
fi
if [ ! -e $config_file ]; then
	echo "JSON file describing imaging files for dcm2bids does not exist: $config_file"
	exit 1
fi



## Run dcm2bids
echo "Running dcm2bids:
dcm2bids -d $sourcedata_dir/$source_participant_dir \
-p $participant_id \
-s $session_id \
-c $config_file \
-o $bids_dir
"
dcm2bids -d $sourcedata_dir/$source_participant_dir \
	-p $participant_id \
	-s $session_id \
	-c $config_file \
	-o $bids_dir \
	--forceDcm2niix

