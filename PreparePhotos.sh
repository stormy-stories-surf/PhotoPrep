#!/bin/bash

PhotoInputDir="Watermark_Test/Photos"
PhotoOutputDir="Watermark_Test/WatermarkedPhotos"
Watermark="Watermark_Test/Watermark/Watermark.png"
declare -a PhotoFileExtension=("JPG" "jpg" "png")

rm -rf ${PhotoOutputDir}
echo "abc ${PhotoOutputDir}"
mkdir ${PhotoOutputDir}

for PhotoFileExtensions in ${PhotoFileExtension}; do
  for FileName in ${PhotoInputDir}/*.${PhotoFileExtensions}; do
    FileWithExtension="$(basename -- ${FileName})"
    File=${FileWithExtension%.*}
    echo "${PhotoOutputDir}/${File}_WM.JPG"
    composite -gravity SouthWest -geometry +10+10 ${Watermark} ${PhotoInputDir}/${FileWithExtension} ${PhotoOutputDir}/${File}_WM.JPG
    echo "${File}"
  done;
done;

for FileName in ${PhotoOutputDir}/*.JPG; do
  File="$(basename -- ${FileName})"
  convert ${i} -quality 50% ${PhotoOutputDir}/${File}_50p.JPG
done;
