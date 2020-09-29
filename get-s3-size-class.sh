yesterday=$(date -d @$((($(date +%s)-86400))) +%F)
for bucket in `aws --profile ABC s3api list-buckets --query 'Buckets[*].Name' --output text`; do
sclass=$(aws --profile ABC s3api list-objects --bucket $bucket --max-items=1 2> /dev/null | jq -r '.Contents[].StorageClass // "STANDARD"')
case $sclass in
  REDUCED_REDUNDANCY) sclass="ReducedRedundancyStorage" ;;
  GLACIER)            sclass="GlacierStorage" ;;
  DEEP_ARCHIVE)       sclass="DeepArchiveStorage" ;;
  STANDARD_IA)        sclass="StandardIAStorage" ;;
  ONEZONE_IA)         sclass="OneZoneIAStorage" ;;
  *)                  sclass="StandardStorage" ;;
esac
size=$(aws --profile ABC cloudwatch get-metric-statistics --namespace AWS/S3 --start-time ${yesterday}T00:00:00 --end-time $(date +%F)T00:00:00 --period 86400 --metric-name BucketSizeBytes --dimensions Name=StorageType,Value=$sclass Name=BucketName,Value=$bucket --statistics Average --output text --query 'Datapoints[0].Average')
#printf $(echo $bucket)
#printf $(echo $sclass)
echo $bucket,$sclass,$size
done
