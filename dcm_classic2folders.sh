#!/bin/bash

# Move files in classic dicom folders into folders


## Process command line arguments
usage(){ echo "Usage: `basename $0` -d <dicom_dir> 
Use classic DICOM file name convention to organize into folders by series 

d:	path to DICOM folder

Example: `basename $0` -d /path/to/dicomdir
" 1>&2; exit 1; }

if [ $# -lt 2 ]; then
	usage
fi
	
while getopts "d:" opt; do
    case "${opt}" in
        d)
            dcmdir=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


## Check inputs
if [ ! -d $dcmdir ]; then
	echo "Data directory $dcmdir does not exist"
	exit 1
fi

cd "$dcmdir"
# dcm2niix_bin=/path/to/dcm2niix


# Move dicom files into separate folders by series
for F in *; do 
	echo $F
	series_str="$(echo $F | cut -d'.' -f4)"
	if [ ${#series_str} -eq 4 ]; then
		series_num=${series_str:0:1}
	elif [ ${#series_str} -eq 5 ]; then
		series_num=${series_str:0:2}
	fi
	echo "series_num $series_num"
# 	if [ ! -d $series_num ]; then
# 		mkdir $series_num
# 	fi
# 	mv $F $series_num/


	# Get scan type
# 	scantype=`dicom_hinfo -no_name -tag 0008,103e $dcmfile` # uses afni dicom_hinfo
	scantype=`dcmdump --print-short --search 0008,103e $F | awk -F'[][]' '{print $2}' | sed -e 's/[[:space:]]*$//' | awk -F '[[:space:]]' '{print $1}'` 
	echo "scantype $scantype"
	
	# Create folder for series if it doesn't exist and move data
	seriesdir=`printf "${scantype}_%04d" "$series_num"`
	
	if [ ! -d "$seriesdir" ]; then
		echo "Creating subdirectory $seriesdir"
		mkdir "$seriesdir"
	fi
	
	mv $F "$seriesdir/"

done

# Run dcm2niix to convert to nifti
# for D in *; do
# 	if [ -d $D ]; then 
# 		echo $D
# 		$dcm2niix_bin -f %p_%s -b y -ba n -o $D $D
# 	fi
# done

