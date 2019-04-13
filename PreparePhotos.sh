#!/bin/bash
#

#declare changeable parameters
PHOTO_INPUT_DIR="Watermark_Test/Photos"
POST_CATEGORY="Watermark_Test"
POST_NAME="WatermarkedPhotos"
WATERMARK="Watermark_Test/Watermark/Watermark.png"
SIZED_WATERMARK="Watermark_Test/Watermark/SIZED_WATERMARK.png"
COMPRESSION_FACTOR="70"

# create output directory
PHOTO_OUTPUT_DIR="${POST_CATEGORY}/${POST_NAME}"
mkdir -p ${PHOTO_OUTPUT_DIR}

# loop over all images to prepare them bevor upload
for FILE_NAME in ${PHOTO_INPUT_DIR}/*.{JPG,jpg}; do
  FILE_WITH_EXTENSION="$(basename -- ${FILE_NAME})"
  FILE=${FILE_WITH_EXTENSION%.*}
  # check if the converted image already exists
  if ! [ -f "${PHOTO_OUTPUT_DIR}/windsurf-stormy-stories-surf-travel-blog-${POST_CATEGORY}-${POST_NAME}-WM-${COMPRESSION_FACTOR}p-${FILE}.JPG" ]; then

    # calculate a vector to resize the watermark depending in the image size and finaly resize the watermark
    VARIABLE_HEIGHT=$(identify -ping -format '%h' ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} )
    VARIABLE_WIDTH=$(identify -ping -format '%w' ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} )
    #ImageSize=$((${VARIABLE_HEIGHT}*${VARIABLE_WIDTH})) ?? Version 0.3.0  calculate a vector for panorama pictures
    #Vector="$(bc -l <<< "($ImageSize / 20256000)*100")%"
    VECTOR="$(bc -l <<< "($VARIABLE_WIDTH / 6000)*100")%"
    convert ${WATERMARK} -resize ${VECTOR} ${SIZED_WATERMARK}
    # watermark the image
    composite -gravity SouthWest -geometry +10+10   ${SIZED_WATERMARK} ${PHOTO_INPUT_DIR}/${FILE_WITH_EXTENSION} "${PHOTO_OUTPUT_DIR}/${FILE}-WM.JPG"
    # erase the metadata out of the image
    jhead -purejpg "${PHOTO_OUTPUT_DIR}/${FILE}-WM.JPG"
    # compress the image
    convert "${PHOTO_OUTPUT_DIR}/${FILE}-WM.JPG" -quality "${COMPRESSION_FACTOR}%" "${PHOTO_OUTPUT_DIR}/${FILE}-WM-${COMPRESSION_FACTOR}p.JPG"
    # rename the image for serch engine optimization
    mv -v "${PHOTO_OUTPUT_DIR}/${FILE}-WM-${COMPRESSION_FACTOR}p.JPG" "${PHOTO_OUTPUT_DIR}/windsurf-stormy-stories-surf-travel-blog-${POST_CATEGORY}-${POST_NAME}-WM-${COMPRESSION_FACTOR}p-${FILE}.JPG"
    echo "Finished Image "${FILE_NAME}
  else
    echo "Image ${FILE_NAME} already converted"
  fi
done;
