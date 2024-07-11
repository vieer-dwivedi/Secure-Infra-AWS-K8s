terraform {
    source = "../../../infra-modules/s3_bucket_policy"
}

include "root"{
    path = find_in_parent_folders()
}

include "env"{
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

inputs = {
	env = include.env.locals.env
    bucket_name = dependency.s3.outputs.s3_bucket_name
    cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id
}

dependency "cloudfront"{
	config_path = "../cloudfront"

	mock_outputs ={
	    cloudfront_distribution_id = "E1234567891011"
	}
}

dependency "s3"{
	config_path = "../s3"
	mock_outputs ={
	    s3_bucket_name = "my-test-bucket"
	}
}
