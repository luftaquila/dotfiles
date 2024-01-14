########################################
# S.M.A.R.T
########################################
sudo smartctl -a /dev/<disk> # disk info
sudo smartctl -t long /dev/<disk> # test

########################################
# backup
########################################
sudo mount /dev/<disk> /mnt/backup
rsync -avxhHAWXS --numeric-ids --info=progress2 --exclude='' source dest
sudo umount /dev/<disk>
