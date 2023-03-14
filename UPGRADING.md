# Upgrading from the previous Hydra version of parquet_s3_fdw

In the previous version of Hydra's parquet_s3_fdw, `aws_region` was added to be able
to select the S3 region.

`aws_region` will continue to be supported, but it is considered _deprecated_ and will
be removed some time in the future.

Please switch to using `region` as the `OPTION` for instead of `aws_region`.

See [README.md](README.md) for more information on supported options.
