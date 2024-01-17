########################################
# S.M.A.R.T
########################################
sudo smartctl -a /dev/<disk>
sudo smartctl -t short /dev/<disk>
sudo smartctl -t long /dev/<disk>

########################################
# backup
########################################
sudo mount /dev/<disk> /mnt/backup
rsync -avxhHAWXS --numeric-ids --info=progress2 --exclude='' source dest
sudo umount /dev/<disk>

sudo mount /dev/sdb /mnt/backup
rsync -avxhHAWXS --numeric-ids --info=progress2 --exclude='' /mnt/disk/cloud /mnt/backup
sudo umount /dev/sdb
