#!/bin/bash
# Add pcidss compliance
#panel - Applying security changes for sw-cp-server (nginx for Plesk).
#apache - Applying security changes for Apache server.
#courier - Applying security changes for Courier IMAP.
#dovecot - Applying security changes for Dovecot.
#qmail - Applying security changes for qmail.
#postfix - Applying security changes for Postfix MTA.
#proftpd - Applying security changes for ProFTPd.
#all - Applying security changes for all installed services described above. This is a default value.

# More informations here: https://docs.plesk.com/en-US/obsidian/administrator-guide/plesk-administration/securing-plesk/pci-dss-compliance/tune-plesk-to-meet-pci-dss-on-linux.78899/
/usr/sbin/plesk sbin pci_compliance_resolver --enable all
