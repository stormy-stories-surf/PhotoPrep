#!/bin/bash
#


function usage {
    cat <<EOF

    Anwendung: terminal im INPUT_DIR öffnen eingabe: " photoprep -wm='' -o'' "

    parameter um von standard parametern aohbzuweichen
    -set -> in verbindung mit anderem Parameter um das parameter in Standard_Parameter.txt
    -wm '' -> ändert das watermark: 'wht' -> Watermark_wht.png, 'blk' -> Watermark_blk.png
    -o '' -> ändert die orientierung: 'nw' -> NorthWest, 'n' -> North, 'ne' -> NorthEast, 'w' -> West, 'c' -> Center, 'e' -> East, 'sw' -> SouthWest, 's' -> South, 'se' -> SouthEast
    -ow '' -> ändert offset_width
    -oh '' -> ändert offset_height
    -c '' -> ändert den komprimierungs factor
    -dir '' -> andert das output dir

EOF
    exit $1
}

#declare changeable parameters
PHOTO_INPUT_DIR="Watermark_Test/Photos"
POST_CATEGORY="Watermark_Test"
POST_NAME="WatermarkedPhotos"
#default parameters -> later set in external file
set="0"
WATERMARK="Watermark_Test/Watermark/Watermark.png"
WATERMARK_ORIENTATION="SouthWest"
OFFSET_WIDTH="10"
OFFSET_HEIGHT="10"
COMPRESSION_FACTOR="35"
dir=


#temporary variables/files
SIZED_WATERMARK="Watermark_Test/Watermark/SIZED_WATERMARK.png"
REMEMBERED_iMAGE_SIZE="0"


for i in $*; do
  case "$i" in
    -set)
      set="1"
    ;;
    -wm=*)
      wm_temp=${i#-wm=}
      case "$wm_temp" in
        wht) WATERMARK="Watermark_wht.png" ;;
        blk)  WATERMARK="Watermark_blk.png" ;;
        *.png) WATERMARK=${wm_temp} ;;
        *) echo "unknown watermark '${wm_temp}'"
           usage 1 ;;
      esac
    ;;
    -o=*)
      o_temp=${i#-o=}
      case "$o_temp" in
        nw|NW|NorthWest|northwest) WATERMARK_ORIENTATION="NorthWest" ;;
        n|N|North|north) WATERMARK_ORIENTATION="North" ;;
        ne|NE|NorthEast|northeast) WATERMARK_ORIENTATION="NorthEast" ;;
        w|W|West|west) WATERMARK_ORIENTATION="West" ;;
        c|C|Center|center) WATERMARK_ORIENTATION="Center" ;;
        e|E|East|east) WATERMARK_ORIENTATION="East" ;;
        sw|SW|SouthWest|southwest) WATERMARK_ORIENTATION="SouthWest" ;;
        s|S|South|south) WATERMARK_ORIENTATION="South" ;;
        se|SE|SouthEast|southeast) WATERMARK_ORIENTATION="SouthEast" ;;
        *)  echo "unknown orietation '${o_temp}'"
            usage 1 ;;
      esac
        ;;
    -ow=*)
        OFFSET_WIDTH=${i#-ow=}
        ;;
    -oh=*)
        OFFSET_HEIGHT=${i#-oh=}
        ;;
    -c=*)
        COMPRESSION_FACTOR=${i#-c=}
        ;;
    -dir=*)
        dir=${i#-dir=}
        ;;
    -h)
        usage 0
        ;;
    -help)
        usage 0
        ;;
    -*)
        echo "unknown option '$i'"
        usage 1
        ;;
    *)
        usage 1
        ;;
  esac
done;


echo "${set}"
echo "${WATERMARK}"
echo "${WATERMARK_ORIENTATION}"
echo "${OFFSET_WIDTH}"
echo "${OFFSET_HEIGHT}"
echo "${COMPRESSION_FACTOR}"
echo "${dir}"

# create output directory
PHOTO_OUTPUT_DIR="${POST_CATEGORY}/${POST_NAME}"
mkdir -p ${PHOTO_OUTPUT_DIR}

# loop over all images to prepare them bevor upload
for FILE_NAME in ${PHOTO_INPUT_DIR}/*.*; do
  if [ ${FILE_NAME##*.} == "JPG" ]  || [ ${FILE_NAME##*.} == "jpg" ] || [ ${FILE_NAME##*.} == "png" ]; then
    # cut of path and extension
    FILE_WITH_EXTENSION="$(basename -- ${FILE_NAME})"
    FILE=${FILE_WITH_EXTENSION%.*}

    OUTPUT_FILE_NAME="${FILE}-WM.jpg"
    OUTPUT_FILE_NAME_COMPRESSED="windsurf-stormy-stories-surf-travel-blog-${POST_CATEGORY}-${POST_NAME}-WM-${COMPRESSION_FACTOR}p-${FILE}.jpg"

    # check if the converted image already exists
    if ! [ -f "${PHOTO_OUTPUT_DIR}/${OUTPUT_FILE_NAME_COMPRESSED}" ]; then

      # calculate a vector to resize the watermark depending in the image size and finaly resize the watermark
      VARIABLE_HEIGHT=$(identify -ping -format '%h' ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} )
      VARIABLE_WIDTH=$(identify -ping -format '%w' ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} )
      #ImageSize=$((${VARIABLE_HEIGHT}*${VARIABLE_WIDTH})) ?? Version 0.3.0  calculate a vector for panorama pictures
      #Vector="$(bc -l <<< "($ImageSize / 20256000)*100")%"

      # check if resize is nessesary
      if ! [ ${REMEMBERED_iMAGE_SIZE} == ${VARIABLE_WIDTH} ]; then
        VECTOR="$(bc -l <<< "($VARIABLE_WIDTH / 6000)*100")%"
        convert ${WATERMARK} -resize ${VECTOR} ${SIZED_WATERMARK}
        REMEMBERED_iMAGE_SIZE=${VARIABLE_WIDTH}
      fi

      # watermark the image
      composite -gravity SouthWest -geometry +${OFFSET_WIDTH}+${OFFSET_HEIGHT}   ${SIZED_WATERMARK} ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} "${PHOTO_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"

      # erase the metadata out of the image
      jhead -purejpg "${PHOTO_OUTPUT_DIR}/${OUTPUT_FILE_NAME}"

      # compress the image
      convert "${PHOTO_OUTPUT_DIR}/${OUTPUT_FILE_NAME}" -quality "${COMPRESSION_FACTOR}%" "${PHOTO_OUTPUT_DIR}/${OUTPUT_FILE_NAME_COMPRESSED}"

      echo "Finished Image "${OUTPUT_FILE_NAME_COMPRESSED}
    else
      echo "Image ${FILE_NAME} already converted"
    fi
  fi
done;
