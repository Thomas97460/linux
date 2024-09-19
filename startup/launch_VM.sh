#!/bin/bash

# Initialiser les variables
TAP1=""
TAP2=""
TAG=""
IMAGE_NAME_1=""
IMAGE_NAME_2=""

# Analyser les options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -tap1) TAP1="$2"; shift ;;
    -tap2) TAP2="$2"; shift ;;
    -tag) TAG="$2"; shift ;;
    -image_name_1) IMAGE_NAME_1="$2"; shift ;;
    -image_name_2) IMAGE_NAME_2="$2"; shift ;;
    *) echo "Usage: $0 -tap1 <tap1_number> -tap2 <tap2_number> -tag <tag> -image_name_1 <image_name_1> -image_name_2 <image_name_2>"; exit 1 ;;
  esac
  shift
done

# Vérifiez que tous les arguments sont fournis
if [ -z "$TAP1" ] || [ -z "$TAP2" ] || [ -z "$TAG" ] || [ -z "$IMAGE_NAME_1" ] || [ -z "$IMAGE_NAME_2" ]; then
  echo "Usage: $0 -tap1 <tap1_number> -tap2 <tap2_number> -tag <tag> -image_name_1 <image_name_1> -image_name_2 <image_name_2>"
  exit 1
fi

# Fichiers YAML à modifier
YAML_SWITCH="switch.yaml"
YAML_LAB="lab.yaml"

# Modifier les numéros de tap et le tag dans le fichier switch.yaml
awk -v tap1="tap${TAP1}" -v tap2="tap${TAP2}" -v tag="${TAG}" '
  BEGIN { count_name = 0; count_tag = 0 }
  /name:/ {
    count_name++
    if (count_name == 2) {
      sub(/name:.*/, "name: " tap1)
    } else if (count_name == 3) {
      sub(/name:.*/, "name: " tap2)
    }
  }
  /tag:/ {
    count_tag++
    if (count_tag == 1) {
      sub(/tag:.*/, "tag: " tag)
    } else if (count_tag == 2) {
      sub(/tag:.*/, "tag: " tag)
    }
  }
  { print }
' $YAML_SWITCH > temp_switch.yaml && mv temp_switch.yaml $YAML_SWITCH

# Modifier la première occurrence de vm_name, dev_name et tapnum dans le fichier lab.yaml
awk -v vm_name1="${IMAGE_NAME_1}" -v dev_name1="${IMAGE_NAME_1}-disk.qcow2" -v tapnum1="${TAP1}" '
  BEGIN { count_vm_name = 0; count_dev_name = 0; count_tapnum = 0 }
  /vm_name:/ {
    count_vm_name++
    if (count_vm_name == 1) {
      sub(/vm_name:.*/, "vm_name: " vm_name1)
    }
  }
  /dev_name:/ {
    count_dev_name++
    if (count_dev_name == 1) {
      sub(/dev_name:.*/, "dev_name: " dev_name1)
    }
  }
  /tapnum:/ {
    count_tapnum++
    if (count_tapnum == 1) {
      sub(/tapnum:.*/, "tapnum: " tapnum1)
    }
  }
  { print }
' $YAML_LAB > temp_lab.yaml && mv temp_lab.yaml $YAML_LAB

# Modifier la deuxième occurrence de vm_name, dev_name et tapnum dans le fichier lab.yaml
awk -v vm_name2="${IMAGE_NAME_2}" -v dev_name2="${IMAGE_NAME_2}-disk.qcow2" -v tapnum2="${TAP2}" '
  BEGIN { count_vm_name = 0; count_dev_name = 0; count_tapnum = 0 }
  /vm_name:/ {
    count_vm_name++
    if (count_vm_name == 2) {
      sub(/vm_name:.*/, "vm_name: " vm_name2)
    }
  }
  /dev_name:/ {
    count_dev_name++
    if (count_dev_name == 2) {
      sub(/dev_name:.*/, "dev_name: " dev_name2)
    }
  }
  /tapnum:/ {
    count_tapnum++
    if (count_tapnum == 2) {
      sub(/tapnum:.*/, "tapnum: " tapnum2)
    }
  }
  { print }
' $YAML_LAB > temp_lab.yaml && mv temp_lab.yaml $YAML_LAB

# Exécuter les scripts
~/masters/scripts/switch-conf.py $YAML_SWITCH
~/masters/scripts/lab-startup.py $YAML_LAB