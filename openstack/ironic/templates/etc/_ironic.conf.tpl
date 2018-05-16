[DEFAULT]
log-config-append = /etc/ironic/logging.ini
pybasedir = /ironic/ironic
network_provider = neutron_plugin
enabled_network_interfaces = noop,flat,neutron
default_network_interface = neutron

rpc_response_timeout = {{ .Values.rpc_response_timeout | default .Values.global.rpc_response_timeout | default 60 }}
rpc_workers = {{ .Values.rpc_workers | default .Values.global.rpc_workers | default 1 }}

[agent]
deployLogs_collect = {{ .Values.agent.deployLogs.collect }}
deployLogs_storageBackend = {{ .Values.agent.deployLogs.storageBackend }}
deployLogs_imageRepository = {{ .Values.agent.deployLogs.imageRepository }}
{{- if eq .Values.agent.deployLogs.storageBackend "swift" }}
deployLogs_imageRepository = {{ .Values.agent.deployLogs.imageRepository | required "Need a project name" }}
deployLogs_swiftProjectDomainName = {{ .Values.agent.deployLogs.swiftProjectDomainName | required "Need a domain name for the project" }}
deployLogs_swift_container = {{ .Values.agent.deployLogs.swift_container | default "ironic_deployLogs_container" }}
{{- end }}

[inspector]
enabled=True
auth_section = service_catalog
service_url=https://{{include "ironic_inspector_endpoint_host_public" .}}

[dhcp]
dhcp_provider=neutron

[api]
host_ip = 0.0.0.0

{{- include "ini_sections.database" . }}

[keystone]
auth_section = service_catalog
region = {{ .Values.global.region }}

[keystone_authtoken]
auth_section = service_catalog
auth_uri = {{.Values.global.keystone_api_endpoint_protocol_admin | default "http" }}://{{include "keystone_api_endpoint_host_admin" .}}:{{ .Values.global.keystone_api_port_admin }}/v3
memcache_servers = {{include "memcached_host" .}}:{{.Values.global.memcached_port_public | default 11211}}

[service_catalog]
auth_section = service_catalog
insecure = True
# auth_section
auth_type = v3password
auth_url = {{.Values.global.keystone_api_endpoint_protocol_admin | default "http" }}://{{include "keystone_api_endpoint_host_admin" .}}:{{ .Values.global.keystone_api_port_admin | default 35357}}/v3
user_domain_name = {{.Values.global.keystone_service_domain | default "Default"}}
username = {{ .Values.global.ironicServiceUser }}{{ .Values.global.user_suffix }}
password = {{ .Values.global.ironicServicePassword | default (tuple . .Values.global.ironicServiceUser | include "identity.password_for_user")  | replace "$" "$$" }}
project_domain_name = {{.Values.global.keystone_service_domain | default "Default"}}
project_name = {{.Values.global.keystone_service_project | default "service"}}

[glance]
auth_section = service_catalog
glance_api_servers = {{.Values.global.glance_api_endpoint_protocol_internal | default "http"}}://{{include "glance_api_endpoint_host_internal" .}}:{{.Values.global.glance_api_portInternal | default 9292}}
swift_temp_url_duration=1200
# No terminal slash, it will break the url signing scheme
swift_endpoint_url={{.Values.global.swift_endpoint_protocol | default "http"}}://{{include "swift_endpoint_host" .}}:{{ .Values.global.swift_api_port_public | default 443}}
swift_api_version=v1
{{- if .Values.swiftStoreMultiTenant }}
swiftStoreMultiTenant = True
{{- else}}
    {{- if .Values.swiftMultiTenant }}
swift_store_multiple_containers_seed=32
    {{- end }}
swift_temp_url_key={{ .Values.swiftTempurl }}
swiftAccount={{ .Values.swiftAccount }}
{{- end }}

[swift]
auth_section = service_catalog
{{- if .Values.swiftSetTempUrlKey }}
swiftSetTempUrlKey = True
{{- end }}

[neutron]
auth_section = service_catalog
url = {{.Values.global.neutron_api_endpoint_protocol_internal | default "http"}}://{{include "neutron_api_endpoint_host_internal" .}}:{{ .Values.global.neutron_api_portInternal | default 9696}}
cleaning_network_uuid = {{ .Values.network_cleaning_uuid }}
provisioning_network_uuid = {{ .Values.network_management_uuid }}

{{include "oslo_messaging_rabbit" .}}

[oslo_middleware]
enable_proxy_headers_parsing = True

{{- include "osprofiler" . }}
