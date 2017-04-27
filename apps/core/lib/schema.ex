
import Builder
defschema Manifest.DockerConfig,[
      :architecture,
      :config,
      :container,
      :container_config,
      :created,
      :docker_version,
      :history,
      :os,
      :rootfs]
defschema Manifest.ContainerConfig,[
      :Hostname,
      :Domainname,
      :User,
      :AttachStdin,
      :AttachStdout,
      :AttachStderr,
      :ExposedPorts,
      :Tty,
      :OpenStdin,
      :StdinOnce,
      :Env,
      :Cmd,
      :Image,
      :Volumes,
      :WorkingDir,
      :Entrypoint,
      :OnBuild,
      :Labels,
      ]

defschema Manifest.DockerConfigHistory,[
      :created,
      :created_by,
      :empty_layer,
      ]

defschema Manifest.V1Schema,[
      :schemaVersion,
      :name,
      :tag,
      :architecture,
      :fsLayers,
      :history,
      :signatures,
      ]

defschema Manifest.V1Compatibility,[
      :architecture,
      :config,
      :container,
      :docker_version,
      :os,
      :id,
      :parent,
      :comment,
      :created,
      :container_config,
      :author,
      :throwaway,
    ]

defschema Manifest.V1History,[
      :v1Compatibility
    ]

defschema Manifest.FsLayers,[
      :blobSum
    ]
