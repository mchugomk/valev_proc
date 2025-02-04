#!/bin/bash

# Modified from code snippet by Joel Stoddard
# - changed from requiring afni dicom_hinfo to using dtmtk dcmdump because of MRS scans

## Process command line arguments
usage(){ echo "Usage: `basename $0` --dicomdir <dicomdir>
dicomdir: Full path to directory containing dicom files

Take directory dicom files from BIC and organize them into subfolders.
Subfolders will be named by scan type (e.g t1_mprage_ax_p2) and series number (e.g. 0005): t1_mprage_ax_p2_0005

Example: `basename $0` --dicomdir /path/to/dicom_data
" 1>&2; exit 1; }


if [ $# -ne 2 ]; then
	usage
fi

# Parse input options
while [[ $# -gt 0 ]]
do
    case "$1" in

        --dicomdir)
            # Full path to directory containing dicom files
            export dicomdir="$2"; shift; shift ;;
		*)
			# Handle any unrecognized options
            usage
            ;;

    esac
done

if [ ! -d $dicomdir ]; then
	echo "Dicom directory does not exist"
	usage
fi

cd $dicomdir 

if compgen -G "*.dcm" > /dev/null; then

	for dcmfile in *.dcm; do
	
		# Get series number from filename
		seriesnum=`cut -d. -f4 <<< $dcmfile`
		
		# Get scan type
	# 	scantype=`dicom_hinfo -no_name -tag 0008,103e $dcmfile` # uses afni dicom_hinfo
		scantype=`dcmdump --print-short --search 0008,103e $dcmfile | awk -F'[][]' '{print $2}' | sed -e 's/[[:space:]]*$//' | awk -F '[[:space:]]' '{print $1}'` 
	# 	echo "scantype $scantype"
		
		# Create folder for series if it doesn't exist and move data
		seriesdir=$series
		seriesdir=`printf "${scantype}_%04d" "$seriesnum"`
		
		if [ ! -d "$seriesdir" ]; then
			echo "Creating subdirectory $seriesdir"
			mkdir "$seriesdir"
		fi
		
		mv $dcmfile "$seriesdir"
		
	done

else
	echo "No DICOM .dcm files found in $dicomdir"
	usage
fi

