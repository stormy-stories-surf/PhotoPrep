#!/bin/bash

PhotoInputDir="Watermark_Test/Photos"
PhotoOutputDir="Watermark_Test/WatermarkedPhotos"
Watermark="Watermark_Test/Watermark/Watermark.png"
SizedWatermark="Watermark_Test/Watermark/SizedWatermark.png"
declare -a PhotoFileExtension=("JPG" "jpg" "png")

rm -rf ${PhotoOutputDir}
mkdir ${PhotoOutputDir}

for FileName in ${PhotoInputDir}/*.{JPG,jpg}; do
  FileWithExtension="$(basename -- ${FileName})"
  File=${FileWithExtension%.*}
  VARIABLE_HEIGHT=$(identify -ping -format '%h' ${PhotoInputDir}/${FileWithExtension} )
  VARIABLE_WIDTH=$(identify -ping -format '%w' ${PhotoInputDir}/${FileWithExtension} )
  #ImageSize=$((${VARIABLE_HEIGHT}*${VARIABLE_WIDTH})) ?? Version 0.3.0  calculate a vector for panorama pictures
  #Vector="$(bc -l <<< "($ImageSize / 20256000)*100")%"
  Vector="$(bc -l <<< "($VARIABLE_WIDTH / 6000)*100")%"
  convert ${Watermark} -resize ${Vector} ${SizedWatermark}
  composite -gravity SouthWest -geometry +10+10   ${SizedWatermark} ${PhotoInputDir}/${FileWithExtension} ${PhotoOutputDir}/${File}_WM.JPG
  echo ${FileName} ${VARIABLE_HEIGHT} ${VARIABLE_WIDTH} ${ImageSize} ${Vector}
done;


#for FileName in ${PhotoOutputDir}/*.JPG; do
#  FileWithExtension="$(basename -- ${FileName})"
#  File=${FileWithExtension%.*}
#  convert ${FileName} -quality 50% ${PhotoOutputDir}/${File}_50p.JPG
#done;
