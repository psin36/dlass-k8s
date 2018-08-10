------------PODSPEC------------
v1.PodSpec{
    Volumes: {
        {
            Name:         "volume-psin",
            VolumeSource: v1.VolumeSource{
                HostPath:              (*v1.HostPathVolumeSource)(nil),
                EmptyDir:              (*v1.EmptyDirVolumeSource)(nil),
                GCEPersistentDisk:     (*v1.GCEPersistentDiskVolumeSource)(nil),
                AWSElasticBlockStore:  (*v1.AWSElasticBlockStoreVolumeSource)(nil),
                GitRepo:               (*v1.GitRepoVolumeSource)(nil),
                Secret:                (*v1.SecretVolumeSource)(nil),
                NFS:                   (*v1.NFSVolumeSource)(nil),
                ISCSI:                 (*v1.ISCSIVolumeSource)(nil),
                Glusterfs:             (*v1.GlusterfsVolumeSource)(nil),
                PersistentVolumeClaim: &v1.PersistentVolumeClaimVolumeSource{ClaimName:"pvc-psin", ReadOnly:false},
                RBD:                   (*v1.RBDVolumeSource)(nil),
                FlexVolume:            (*v1.FlexVolumeSource)(nil),
                Cinder:                (*v1.CinderVolumeSource)(nil),
                CephFS:                (*v1.CephFSVolumeSource)(nil),
                Flocker:               (*v1.FlockerVolumeSource)(nil),
                DownwardAPI:           (*v1.DownwardAPIVolumeSource)(nil),
                FC:                    (*v1.FCVolumeSource)(nil),
                AzureFile:             (*v1.AzureFileVolumeSource)(nil),
                ConfigMap:             (*v1.ConfigMapVolumeSource)(nil),
                VsphereVolume:         (*v1.VsphereVirtualDiskVolumeSource)(nil),
                Quobyte:               (*v1.QuobyteVolumeSource)(nil),
                AzureDisk:             (*v1.AzureDiskVolumeSource)(nil),
                PhotonPersistentDisk:  (*v1.PhotonPersistentDiskVolumeSource)(nil),
                Projected:             (*v1.ProjectedVolumeSource)(nil),
                PortworxVolume:        (*v1.PortworxVolumeSource)(nil),
                ScaleIO:               (*v1.ScaleIOVolumeSource)(nil),
                StorageOS:             (*v1.StorageOSVolumeSource)(nil),
            },
        },
    },
    InitContainers: nil,
    Containers:     {
        {
            Name:       "test-learner-container",
            Image:      "registry.ng.bluemix.net/dlaas_dev/tensorflow_gpu_1.5:latest",
            Command:    {"bash", "-c", "echo hello"},
            Args:       nil,
            WorkingDir: "",
            Ports:      {
                {Name:"", HostPort:0, ContainerPort:22, Protocol:"TCP", HostIP:""},
                {Name:"", HostPort:0, ContainerPort:2222, Protocol:"TCP", HostIP:""},
            },
            EnvFrom:   nil,
            Env:       nil,
            Resources: v1.ResourceRequirements{
                Limits: {
                    "cpu": {
                        i:      resource.int64Amount{value:1000, scale:-3},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                    "memory": {
                        i:      resource.int64Amount{value:1024, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                    "alpha.kubernetes.io/nvidia-gpu": {
                        i:      resource.int64Amount{value:1, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                },
                Requests: {
                    "cpu": {
                        i:      resource.int64Amount{value:1000, scale:-3},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                    "memory": {
                        i:      resource.int64Amount{value:1024, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                    "alpha.kubernetes.io/nvidia-gpu": {
                        i:      resource.int64Amount{value:1, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "DecimalSI",
                    },
                },
            },
            VolumeMounts: {
                {
                    Name:             "volume-psin",
                    ReadOnly:         false,
                    MountPath:        "/mnt/s3fs",
                    SubPath:          "",
                    MountPropagation: (*v1.MountPropagationMode)(nil),
                },
            },
            VolumeDevices:            nil,
            LivenessProbe:            (*v1.Probe)(nil),
            ReadinessProbe:           (*v1.Probe)(nil),
            Lifecycle:                (*v1.Lifecycle)(nil),
            TerminationMessagePath:   "",
            TerminationMessagePolicy: "",
            ImagePullPolicy:          "Always",
            SecurityContext:          &v1.SecurityContext{
                Capabilities: &v1.Capabilities{
                    Add:  nil,
                    Drop: {"CHOWN", "DAC_OVERRIDE", "FOWNER", "FSETID", "KILL", "SETPCAP", "NET_RAW", "MKNOD", "SETFCAP"},
                },
                Privileged:               (*bool)(nil),
                SELinuxOptions:           (*v1.SELinuxOptions)(nil),
                RunAsUser:                (*int64)(nil),
                RunAsGroup:               (*int64)(nil),
                RunAsNonRoot:             (*bool)(nil),
                ReadOnlyRootFilesystem:   (*bool)(nil),
                AllowPrivilegeEscalation: (*bool)(nil),
            },
            Stdin:     false,
            StdinOnce: false,
            TTY:       false,
        },
    },
    RestartPolicy:                 "",
    TerminationGracePeriodSeconds: (*int64)(nil),
    ActiveDeadlineSeconds:         (*int64)(nil),
    DNSPolicy:                     "",
    NodeSelector:                  {},
    ServiceAccountName:            "",
    DeprecatedServiceAccount:      "",
    AutomountServiceAccountToken:  &bool(false),
    NodeName:                      "",
    HostNetwork:                   false,
    HostPID:                       false,
    HostIPC:                       false,
    ShareProcessNamespace:         (*bool)(nil),
    SecurityContext:               (*v1.PodSecurityContext)(nil),
    ImagePullSecrets:              {
        {Name:"bluemix-cr-ng"},
    },
    Hostname:  "",
    Subdomain: "",
    Affinity:  &v1.Affinity{
        NodeAffinity: &v1.NodeAffinity{
            RequiredDuringSchedulingIgnoredDuringExecution: &v1.NodeSelector{
                NodeSelectorTerms: {
                    {
                        MatchExpressions: {
                            {
                                Key:      "failure-domain.beta.kubernetes.io/zone",
                                Operator: "In",
                                Values:   {""},
                            },
                        },
                        MatchFields: nil,
                    },
                },
            },
            PreferredDuringSchedulingIgnoredDuringExecution: nil,
        },
        PodAffinity:     (*v1.PodAffinity)(nil),
        PodAntiAffinity: (*v1.PodAntiAffinity)(nil),
    },
    SchedulerName: "",
    Tolerations:   {
        {
            Key:               "dedicated",
            Operator:          "Equal",
            Value:             "gpu-task",
            Effect:            "NoSchedule",
            TolerationSeconds: (*int64)(nil),
        },
    },
    HostAliases:       nil,
    PriorityClassName: "",
    Priority:          (*int32)(nil),
    DNSConfig:         (*v1.PodDNSConfig)(nil),
    ReadinessGates:    nil,
}
------------LIST PVC------------
[]v1.PersistentVolumeClaim{
    {
        TypeMeta:   v1.TypeMeta{Kind:"PersistentVolumeClaim", APIVersion:"v1"},
        ObjectMeta: v1.ObjectMeta{
            Name:                       "pvc-psin",
            GenerateName:               "",
            Namespace:                  "default",
            SelfLink:                   "",
            UID:                        "",
            ResourceVersion:            "",
            Generation:                 0,
            CreationTimestamp:          v1.Time{},
            DeletionTimestamp:          (*v1.Time)(nil),
            DeletionGracePeriodSeconds: (*int64)(nil),
            Labels:                     {},
            Annotations:                {"volume.beta.kubernetes.io/storage-class":"ibmc-s3fs-standard", "ibm.io/endpoint":"https://s3-api.us-geo.objectstorage.service.networklayer.com", "s3fs-fuse-retry-count":"30", "parallel-count":"5", "kernel-cache":"true", "chunk-size-mb":"52", "ibm.io/object-path":"", "ibm.io/secret-name":"test-secret", "ibm.io/auto-delete-bucket":"false", "debug-level":"warn", "ibm.io/bucket":"imagenet-tfrecord", "tls-cipher-suite":"DEFAULT", "multireq-max":"20", "cache-size-gb":"25", "ensure-disk-free":"10", "stat-cache-size":"100000", "curl-debug":"false", "ibm.io/region":"us-standard", "ibm.io/auto-create-bucket":"false"},
            OwnerReferences:            nil,
            Initializers:               (*v1.Initializers)(nil),
            Finalizers:                 nil,
            ClusterName:                "",
        },
        Spec: v1.PersistentVolumeClaimSpec{
            AccessModes: {"ReadWriteOnce"},
            Selector:    (*v1.LabelSelector)(nil),
            Resources:   v1.ResourceRequirements{
                Limits: {
                    "cpu": {
                        i:      resource.int64Amount{value:8, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "8",
                        Format: "DecimalSI",
                    },
                    "memory": {
                        i:      resource.int64Amount{value:34359738368, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "BinarySI",
                    },
                    "alpha.kubernetes.io/nvidia-gpu": {
                        i:      resource.int64Amount{value:21474836480, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "20Gi",
                        Format: "BinarySI",
                    },
                },
                Requests: {
                    "memory": {
                        i:      resource.int64Amount{value:34359738368, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "",
                        Format: "BinarySI",
                    },
                    "alpha.kubernetes.io/nvidia-gpu": {
                        i:      resource.int64Amount{value:21474836480, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "20Gi",
                        Format: "BinarySI",
                    },
                    "cpu": {
                        i:      resource.int64Amount{value:8, scale:0},
                        d:      resource.infDecAmount{},
                        s:      "8",
                        Format: "DecimalSI",
                    },
                },
            },
            VolumeName:       "volume-psin",
            StorageClassName: (*string)(nil),
            VolumeMode:       (*v1.PersistentVolumeMode)(nil),
        },
        Status: v1.PersistentVolumeClaimStatus{},
    },
}
------------STATEFULSET STATUS------------
v1beta1.StatefulSetStatus{}
------------NUMBER OF READY REPLICAS------------
0
------------LIST PODS------------
[]v1.Pod(nil)