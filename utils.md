# SUPPRIMER TOUS LES FICHIERS DE VM DANS LE REPERTOIRE COURANT
rm -rf *.fd *.qcow2*

# DEMARRER VMs
~/masters/scripts/lab-startup.py startup/lab.yaml

# CONFIGURER SWITCHS
~/masters/scripts/switch-conf.py switch.yaml

# CONFIGURATION RAPIDE
~/utils/scripts/launch_VM.sh -tap1 553 -tap2 554 -tag 115 -image_name_1 client -image_name_2 server

# TUER TOUTES LES VMs
~/utils/kill_vm.sh 

