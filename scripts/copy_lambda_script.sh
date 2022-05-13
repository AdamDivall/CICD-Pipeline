#!/usr/bin/env bash

BUCKET=$1

echo "Deploying lambdas to S3 bucket"
pwd
mkdir -p artifacts
for i in $(ls lambda);
    do
        echo "Zipping:" "$i"
        mkdir -p artifacts/lambda/"$i"
        cp -r lambda/"$i" artifacts/lambda
        cd artifacts/lambda/"$i"
        zip -r lambda_function.zip *
        echo "Copying to S3:" "$i"
        aws s3 cp lambda_function.zip s3://"$BUCKET"/"lambda"/"$i"".zip"
        cd ../../../
    done
echo "Deploying finished"