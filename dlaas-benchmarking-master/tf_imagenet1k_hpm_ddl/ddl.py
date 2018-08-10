# Copyright 2017, 2018 International Business Machines
# Prepared by Geert Janssen <geert@us.ibm.com>

# Integration of DDL in Tensorflow HPM

# This Python module exports the following functions:
# - num_hosts(): number of hosts deployed
# - rank(): MPI rank number assigned to this process
# - size(): total number of MPI ranks (= number of GPUs)
# - local_rank(): id of GPU used by this process
# - init(options): initialize this module
# - all_reduce_n(grads): DDL-reduces all gradient tensors in one go

import os
import tensorflow as tf

# Get some MPI environment variables values:
world_size = int(os.getenv('OMPI_COMM_WORLD_SIZE'))
local_size = int(os.getenv('OMPI_COMM_WORLD_LOCAL_SIZE'))

# The number of nodes (or hosts)
g_num_hosts = world_size // local_size

def num_hosts():
    if g_num_hosts == None:
        raise ValueError(
            'DDL has not been initialized; use ddl.tensorflow.init().')
    return g_num_hosts

# rank runs from 0 to size (excl)
# uniquely identifies each parallel process
g_rank = None

def rank():
    if g_rank == None:
        raise ValueError(
            'DDL has not been initialized; use ddl.tensorflow.init().')
    return g_rank

# size is the total number of GPUs (MPI processes)
# typically product of number of nodes and GPUs per node
g_size = None

def size():
    if g_size == None:
        raise ValueError(
            'DDL has not been initialized; use ddl.tensorflow.init().')
    return g_size

# gpuid runs from 0 to the number of GPUs (excl) per node
# number of GPUs typically the same for each node, say 4
g_gpuid = None

g_local_rank = None # not used
g_local_size = None # not used

def local_rank():
    if g_gpuid == None:
        raise ValueError(
            'DDL has not been initialized; use ddl.tensorflow.init().')
    return g_gpuid

ddl_MDR=None
def init(options):
    """A function which initializes DDL.
    """
    # Dynamically load DDL TF library:
    global ddl_MDR
    if ddl_MDR != None:
        raise RuntimeError('DDL has already been initialized.')
    ddl_MDR = tf.load_op_library('ddl_MDR.so') 

    ddl_config = tf.ConfigProto()
    ddl_config.allow_soft_placement = False
    ddl_config.gpu_options.allow_growth = True

    # Initialize DDL:
    with tf.Session(config=ddl_config) as sess:
        with tf.device('/cpu:0'):
            global g_rank, g_size, g_local_rank, g_local_size, g_gpuid
            g_rank, g_size, g_local_rank, g_local_size, g_gpuid = sess.run(
                ddl_MDR.init(local_size, mode = options))

            # mpi info and assigned GPU:
            print('* rank: %d, size: %d, gpuid: %d, hosts: %d'
                  % (g_rank, g_size, g_gpuid, g_num_hosts))

def allreduce_n(grads, average=True, device_dense='', device_sparse=''):
    # One big AllReduce over all grads.
    #with tf.device(device_dense):
    with tf.device('/gpu:%d' % g_gpuid):
        grads = ddl_MDR.all_reduce_n(grads, op='avg' if average else 'sum')
    return grads

# Intercept tf.Variable constructor:
_tf_Var = tf.Variable.__init__

# Our replacement:
# Insert a Bcast operator that will provide the initial value.
# Mind to enforce a certain consistent execution order across multiple instances.
bcast_op = None
def newVar(self, *args, **kwargs):
  #print("rank: {}, kwargs: {}".format(rank, kwargs))
  if 'trainable' in kwargs and kwargs['trainable'] and 'initial_value' in kwargs:
    name = kwargs['name'] if 'name' in kwargs else 'Anon'
    #print("* Initialized TF variable {}".format(name))
    init_val = kwargs['initial_value']
    del kwargs['initial_value']
    # Mind: init_val could be a callable.
    #print(init_val)
    with tf.device('/gpu:%d' % g_gpuid):
      if callable(init_val):
        init_val = init_val()
        #print(init_val)
      global bcast_op
      if bcast_op is None: # first time
        init_val=ddl_MDR.bcast(init_val)
      else:
        # Enforce execution in order of creation:
        with tf.control_dependencies([bcast_op]):
          init_val=ddl_MDR.bcast(init_val)
      bcast_op = init_val
      #print(init_val)
      #init_val = tf.Print(init_val, [init_val],
      #                    "* (%d) Bcast %s init: " % (rank, name))
      _tf_Var(self, initial_value=init_val, *args, **kwargs)
  else:
    _tf_Var(self, *args, **kwargs)

tf.Variable.__init__ = newVar
