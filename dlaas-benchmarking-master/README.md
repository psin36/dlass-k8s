#### Horovod runs with resnet50

- 4 learners with 2 GPUs each, total of 8 GPUs, P100s
- with batch size 64 with synthetic data
    ```total images/sec: 1258.10
       10000	images/sec: 157.3 +/- 0.1 (jitter = 6.5)	7.757	0.000	0.000
    ```
    
- with batch size 64 with actual data
    ```total images/sec: 844.14
        images/sec: 105.6 +/- 0.1 (jitter = 6.6)	5.584	0.109	0.281
    ```
    

- with batch size 128 with synthic data
    ```total images/sec: 1592.41
       10000	images/sec: 199.1 +/- 0.1 (jitter = 6.6)	7.754	0.000	0.000
    ```
- with batch size 128 with actual data
    ```total images/sec: 1036.02
        10000	images/sec: 129.6 +/- 0.1 (jitter = 9.4)	5.092	0.133	0.406
    ```

### TODO
- run convergence tests
- run other models including alexnet and vggnet