{{- define "ironic_conductor_conf" -}}
{{- $conductor :=  index . 1 -}}
{{- with index . 0 -}}
{{- $tftpIP :=  $conductor.tftpIP | default .Values.tftpIP | default .Values.global.ironicTftpIP  }}
{{- $deploy_port :=  $conductor.tftpIP | default .Values.tftpIP | default .Values.global.ironicTftpIP  }}
[DEFAULT]
enabledDrivers = {{ $conductor.enabledDrivers | default "pxe_ipmitool,agent_ipmitool" }}

[conductor]
api_url = {{.Values.global.keystone_api_endpoint_protocol_admin | default "http"}}://{{include "ironic_api_endpoint_host_public" .}}:{{ .Values.global.ironic_api_port_public | default 443}}
clean_nodes = {{ $conductor.clean_nodes | default "False" }}
automated_clean = {{ $conductor.automated_clean | default "False" }}

[console]
terminal_pid_dir = /shellinabox
terminal_url_scheme = https://{{ include "ironic_console_endpoint_host_public" . }}/{{$conductor.name}}/%(uuid)s/%(expiry)s/%(digest)s
socket_permission = 0666
ssh_command_pattern = sshpass -f %(pw_file)s ssh -oLogLevel=error -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oKexAlgorithms=+diffie-hellman-group1-sha1 -l %(username)s %(address)s
url_auth_digest_secret = {{.Values.console.secret}}

[deploy]
# We expose this directory over http and tftp
http_root = /tftpboot
http_url = {{ .Values.conductor.deploy.protocol }}://{{ $tftpIP }}:{{ .Values.conductor.deploy.port }}/tftpboot

[pxe]
tftp_server = {{ $tftpIP }}
tftp_root = /tftpboot

ipxeEnabled = {{ $conductor.ipxeEnabled | default .Values.conductor.ipxeEnabled | default "False" }}
ipxeUseSwift = {{ $conductor.ipxeUseSwift | default .Values.conductor.ipxeUseSwift | default "False" }}

pxeAppendParams = {{ $conductor.pxeAppendParams | default .Values.conductor.pxeAppendParams }}
pxeBootfileName = {{ $conductor.pxeBootfileName | default .Values.conductor.pxeBootfileName | default "pxelinux.0" }}
{{- if $conductor.ipxeEnabled }}
pxe_config_template = $pybasedir/drivers/modules/ipxe_config.template
{{- else }}
pxe_config_template = /etc/ironic/pxe_config.template
{{- end }}

uefi_pxeBootfileName = ipxe.efi
uefi_pxe_config_template = $pybasedir/drivers/modules/ipxe_config.template
{{- end }}
{{- end }}
