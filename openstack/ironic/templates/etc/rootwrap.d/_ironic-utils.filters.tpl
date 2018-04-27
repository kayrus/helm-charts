# ironic-rootwrap command filters for disk manipulation
# This file should be owned by (and only-writable by) the root user

[Filters]
# ironic/drivers/modules/deploy_utils.py
iscsiadm: CommandFilter, iscsiadm, root

# ironic/common/utils.py
mount: CommandFilter, mount, root
umount: CommandFilter, umount, root
