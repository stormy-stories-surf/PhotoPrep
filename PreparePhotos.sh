#!/bin/bash

PhotoInputDir="Watermark_Test/Photos"
PhotoOutputDir="Watermark_Test/WatermarkedPhotos"
Watermark="Watermark_Test/Watermark/Watermark.png"
declare -a PhotoFileExtension=("JPG" "jpg" "png")

rm -rf ${PhotoOutputDir}
mkdir ${PhotoOutputDir}

for FileName in ${PhotoInputDir}/*.{JPG,jpg,jpeg,png}; do  
  FileWithExtension="$(basename -- ${FileName})"
  File=${FileWithExtension%.*}
  identify ${PhotoInputDir}/${FileWithExtension} -format "%w x %h"
#  convert ${PhotoInputDir}/${FileWithExtension} -ping ${PhotoInputDir}/${FileWithExtension} #-format "%w x %h"
#    composite -gravity SouthWest -geometry +10+10 ${Watermark} ${PhotoInputDir}/${FileWithExtension} ${PhotoOutputDir}/${File}_WM.JPG
done;


#for FileName in ${PhotoOutputDir}/*.JPG; do
#  FileWithExtension="$(basename -- ${FileName})"
#  File=${FileWithExtension%.*}
#  convert ${FileName} -quality 50% ${PhotoOutputDir}/${File}_50p.JPG
#done;
