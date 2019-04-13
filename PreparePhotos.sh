#!/bin/bash
#
PhotoInputDir="Watermark_Test/Photos"
PostCategory="Watermark_Test"
PostName="WatermarkedPhotos"
Watermark="Watermark_Test/Watermark/Watermark.png"
SizedWatermark="Watermark_Test/Watermark/SizedWatermark.png"


PhotoOutputDir="${PostCategory}/${PostName}"
declare -a PhotoFileExtension=("JPG" "jpg" "png")

mkdir -p ${PhotoOutputDir}

for FileName in ${PhotoInputDir}/*.{JPG,jpg}; do
  FileWithExtension="$(basename -- ${FileName})"
  File=${FileWithExtension%.*}
  if ! [ -f "${PhotoOutputDir}/windsurf-stormy-stories-surf-travel-blog-${PostCategory}-${PostName}-WM-50p-${File}.JPG" ]; then
    VARIABLE_HEIGHT=$(identify -ping -format '%h' ${PhotoInputDir}/${FileWithExtension} )
    VARIABLE_WIDTH=$(identify -ping -format '%w' ${PhotoInputDir}/${FileWithExtension} )
    #ImageSize=$((${VARIABLE_HEIGHT}*${VARIABLE_WIDTH})) ?? Version 0.3.0  calculate a vector for panorama pictures
    #Vector="$(bc -l <<< "($ImageSize / 20256000)*100")%"
    Vector="$(bc -l <<< "($VARIABLE_WIDTH / 6000)*100")%"
    convert ${Watermark} -resize ${Vector} ${SizedWatermark}
    composite -gravity SouthWest -geometry +10+10   ${SizedWatermark} ${PhotoInputDir}/${FileWithExtension} "${PhotoOutputDir}/${File}-WM.JPG"
    jhead -purejpg "${PhotoOutputDir}/${File}-WM.JPG"
    convert "${PhotoOutputDir}/${File}-WM.JPG" -quality 50% "${PhotoOutputDir}/${File}-WM-50p.JPG"
    mv "${PhotoOutputDir}/${File}-WM-50p.JPG" "${PhotoOutputDir}/windsurf-stormy-stories-surf-travel-blog-${PostCategory}-${PostName}-WM-50p-${File}.JPG"
    echo "Finished Image "${FileName}
  else
    echo "Image ${FileName} already converted"
  fi
done;
