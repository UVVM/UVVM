bash bitvis_vip_avalon_mm__backup_simple_access/internal_script/jenkins-bitvis_vip_avalon_mm-encrypted-development-simulation.sh
status=$?

bash -ex bitvis_vip_avalon_mm__backup_simple_access/internal_script/destroy_boxes.sh
destroy_status=$?

if [ $status -eq 0 ];then
status=$destroy_status
fi

exit $status
