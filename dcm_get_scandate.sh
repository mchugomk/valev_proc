#!/bin/bash


## Use dcmdump to get study date [tag: (0008,0020)] from DICOM header

# IMA file
# dcmdump --search "0008,0020" VALEV_001_2_161831/HEAD_LEGGET_20181005_142735_479000/AAHEAD_SCOUT_0001/VALEV_001_2.MR.HEAD_LEGGET.0001.0001.2018.10.05.14.52.03.729379.70945025.IMA
# (0008,0020) DA [20181005]                               #   8, 1 StudyDate

# DCM file
# dcmdump --search "0008,0020" VALEV.043.1/AAHead_Scout_0001/VALEV_043_1.MR._.1.1.2023.01.11.10.40.20.26.79732161.dcm 
# (0008,0020) DA [20230111]                               #   8, 1 StudyDate

# Get scan ID with tag 0010,0010
# scantype=`dcmdump --print-short --search 0010,0010 $F | awk -F'[][]' '{print $2}' | sed -e 's/[[:space:]]*$//' | awk -F '[[:space:]]' '{print $1}'` 

dcm_date_tag="0008,0020"
dcm_scanid_tag="0010,0010"


usage(){ echo "Usage: `basename $0` -d <dicom_file>
Use dcmdump to get study date [tag: (0008,0020)] from DICOM header

d:	path to DICOM or IMA file

Example: `basename $0` -d /path/to/dicomfile.dcm
" 1>&2; exit 1; }

if [ $# -lt 2 ]; then
	usage
fi
	
while getopts "d:" opt; do
    case "${opt}" in
        d)
            dcmfile=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


# echo "Processing file $dcmfile"

dcm_scan_date=`dcmdump --search "$dcm_date_tag" $dcmfile | awk -F'[][]' '{print $2}'`
dcm_scanid=`dcmdump --search "$dcm_scanid_tag" $dcmfile | awk -F'[][]' '{print $2}'`

echo "${dcm_scan_date},${dcm_scanid},${dcmfile}"

