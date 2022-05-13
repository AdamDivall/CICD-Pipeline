#!/usr/bin/env bash

BUCKET=$1

for i in $(ls lambda);
    do
        echo "Updating Lambda Function:" "$i"
        aws lambda update-function-code --function-name "$i" --s3-bucket "$BUCKET" --s3-key "lambda/$i.zip" --profile cross-account
    done
echo "Update Finished"