{{- define "share_netapp_conf" -}}
{{- $context := index . 0 -}}
{{- $share := index . 1 -}}
{{- $az := index . 2 -}}
[DEFAULT]
storage_availability_zone = {{$az}}

[netapp-multi]
share_backend_name={{$share.backend_name | default $share.vserver | default "netapp-multi"}}
share_driver=manila.share.drivers.netapp.common.NetAppDriver
{{- if $share.vserver }}
driver_handles_share_servers = false
netapp_vserver={{ $share.vserver }}
{{- else}}
driver_handles_share_servers = true
automatic_share_server_cleanup = true
# Unallocated share servers reclamation time interval (minutes).
unused_share_server_cleanup_interval = {{ $share.share_server_cleanup_interval | default 60 }}
netapp_vserver_name_template = ma_%s
{{- end }}

netapp_storage_family=ontap_cluster
netapp_server_hostname={{$share.host}}
netapp_server_port={{ $share.port | default 443 }}
netapp_transport_type={{ $share.protocol | default "https" }}
netapp_login={{$share.username}}
netapp_password={{$share.password}}
netapp_mtu={{$share.mtu | default 9000 }}

netapp_root_volume_aggregate={{$share.root_volume_aggregate}}
netapp_aggregate_name_search_pattern={{$share.aggregate_search_pattern}}

netapp_lif_name_template = os_%(net_allocation_id)s
netapp_port_name_search_pattern = {{ $share.port_search_pattern  | default "(a0b)" }}

neutron_physical_net_name={{$share.physical_network}}
network_api_class=manila.network.neutron.neutron_network_plugin.NeutronBindNetworkPlugin
{{- if $share.debug }}
netapp_trace_flags=api,method
{{- end }}

# The percentage of backend capacity reserved. Default 0 (integer value)
reserved_share_percentage = {{ $share.reserved_share_percentage | default 5 }}
{{- end -}}
