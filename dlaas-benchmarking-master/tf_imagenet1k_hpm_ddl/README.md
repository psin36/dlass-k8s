TensorFlow HPM - DDL Integration
================================

Author: Geert Janssen  
Email: geert@us.ibm.com  
Date: Dec 6, 2017
Tensorflow version: 1.3, 1.4

Summary for the Impatient
-------------------------

The TensorFlow (TF) High-Performance Models (HPM) provide a collection of popular convolution networks mainly operating on the ImageNet data set with a convenient Python script to train these models in an efficient way. The script provides options to run in various distributed modes. We enhance the script with the option to use the IBM Distributed Deep Learning (DDL) communication library instead of the vanilla capabilities.

Introduction
------------

The High-Performance Models constitute a suite of Python scripts that offer a very easy way for a user to run a TensorFlow training session. Most choices have reasonable defaults, so that in the end just a handful of command-line options need to be specified, such as the model, the batch size and the number of GPUs (if any) among others.

The usefulness of this script was also recognized by Alex Sergeev from Uber who used it as the basis of his Horovod approach to distributed learning. The integration of DDL into the scripts follows a near identical path as was followed by Horovod. In particular, the modifications have been restricted to a single file and all specific Horovod/DDL actions are gated via a few new command-line options. Not using those means that the script can be used as and functions exactly like the (unmodified) vanilla script. 

Technical Details
-----------------

The original HPM scripts are to be found [here](https://github.com/tensorflow/benchmarks). We insist on the version with commit number *f5d85aef2851881001130b28385795bc4c59fa38*.

DDL assumes the availability of `ddl_MDR.so` (Tensorflow-BLC).

As vanilla HPM script you can run it any which way you like.
As DDL script you must specify:

  `--variable_update=ddl`

and optionally set some of the DDL options:

  `--ddl_options="-mode b:4x1"`

Of course for DDL you must run the tf_cnn_benchmarks.py file
as argument to mpirun.
Also, then you must specify just 1 GPU:

  `--num_gpus=1`

Only the file `benchmark_cnn.py` has been modified.
All DDL extensions are to be found in the extra file `ddl.py`.
