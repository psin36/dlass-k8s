
#### provide details on what the tests does

This test runs the tf cnn bencmarks mentiond here `https://github.com/tensorflow/benchmarks/tree/master/scripts/tf_cnn_benchmarks`

### how to run this test

1. The test uses the mounted COS, so the first step would be to mount the COS as secret. `kubectl create -f cos_secrets.yml`
2. The second step is to start container that will run the tests. `kubectl create -f tf_cnn_deployment.yml` . Note the `command` section of the yaml as this contains the test command that will be exectuted to trigger the tests. Feel free to change the command per your need

#### provide details on what sort of patterns is this test testing

#### Missign ATM

- Need more details on the file sizes that this test is testing
- How to measure and record what is being tested

### TODO 

- [ ] add code to run nvidia smi in the background and collect stats