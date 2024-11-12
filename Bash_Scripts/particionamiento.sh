#!/bin/bash

#=== Creo las particiones ====
sudo fdisk /dev/sdc <<EOF
n
p
1


t
8e
w
EOF
sudo fdisk /dev/sdd <<EOF
n
p
1


t
8e
w
EOF
sudo fdisk /dev/sde <<EOF
n
e


+1G
t
82
w
EOF
#===== Formateo la nueva partición extendida de sde como swap y la activo =======
sudo mkswap /dev/sde1

sudo swapon /dev/sde1

#====== Hago persistente la particion extendida ======
echo '/dev/sde1 none swap sw 0 0' | sudo tee -a /etc/fstab

#===== Verifico que el swap ha sido añadido correctamente ====
swapon --show

#===== Creo los Physical Volumes (PV) =====
pvcreate /dev/sdc1 /dev/sdd1 /dev/sde1

#====== Creo los volumenes fisicos =====
sudo vgcreate vg_datos /dev/sdc1

sudo vgcreate vg_temp /dev/sdd1

#======== Creo y formateo el volumen lógico para Docker =====
udo lvcreate -L +10M vg_datos -n lv_docker

sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker

sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/

#======= Creo y formateo el volumen lógico para area =====
sudo mkdir -p /work

sudo lvcreate -L +2.5G vg_datos -n lv_workareas

sudo mkfs.ext4 /dev/mapper/vg_datos-lv_workareas

sudo mount /dev/mapper/vg_datos-lv_workareas /work/

#======= Creo y formateo el volumen lógico para swap =====
sudo lvcreate -L +2.5GB vg_temp -n lv_swap

sudo mkswap /dev/vg_temp/lv_swap

sudo swapon /dev/vg_temp/lv_swap

#===== Verifico si el swap esta activo ======
swapon --show

#==== Montaje persistente ====
echo '/dev/vg_temp/lv_swap none swap sw 0 0' | sudo tee -a /etc/fstab
